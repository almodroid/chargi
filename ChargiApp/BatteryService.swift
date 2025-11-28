import Foundation
import IOKit.ps

struct BatteryReading: Equatable {
    let percentage: Int
    let isCharging: Bool
    let isFullyCharged: Bool
    let timeToEmpty: Int?
    let timeToFullCharge: Int?
    let powerSource: String

    var displayText: String {
        if isFullyCharged { return "Full" }
        if isCharging {
            if let t = timeToFullCharge { return format(minutes: t) }
            return "\(percentage)%"
        } else {
            if let t = timeToEmpty { return format(minutes: t) }
            return "\(percentage)%"
        }
    }

    var menuBarText: String {
        if isFullyCharged { return "\(percentage)% · Full" }
        if isCharging {
            if let t = timeToFullCharge { return "\(percentage)% · \(format(minutes: t))" }
            return "\(percentage)%"
        } else {
            if let t = timeToEmpty { return "\(percentage)% · \(format(minutes: t))" }
            return "\(percentage)%"
        }
    }

    private func format(minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 { return String(format: "%dh %dm", h, m) }
        return String(format: "%dm", m)
    }
}

final class BatteryService {
    private var timer: Timer?
    private let queue = DispatchQueue(label: "battery.service")
    private let appGroup = "group.chargi.app"
    private let showBubbleKey = "pref.showFloatingBubble"
    private let enableWidgetKey = "pref.enableWidgetContent"
    private var runLoopSource: CFRunLoopSource?
    private var observers: [UUID: (BatteryReading) -> Void] = [:]
    private(set) var latest: BatteryReading = BatteryReading(percentage: 0, isCharging: false, isFullyCharged: false, timeToEmpty: nil, timeToFullCharge: nil, powerSource: "")

    func start() {
        update()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.update()
        }
        let ctx = Unmanaged.passUnretained(self).toOpaque()
        let source = IOPSNotificationCreateRunLoopSource(BatteryService.powerChangedCallback, ctx)
        runLoopSource = source?.takeRetainedValue()
        if let s = runLoopSource { CFRunLoopAddSource(CFRunLoopGetCurrent(), s, .defaultMode) }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if let s = runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetCurrent(), s, .defaultMode) }
        runLoopSource = nil
    }

    func update() {
        queue.async { [weak self] in
            guard let self else { return }
            let reading = self.fetch()
            DispatchQueue.main.async {
                self.latest = reading
                for block in self.observers.values { block(reading) }
                self.syncToAppGroup(reading: reading)
            }
        }
    }

    @discardableResult
    func addObserver(_ block: @escaping (BatteryReading) -> Void) -> UUID {
        let id = UUID()
        observers[id] = block
        block(latest)
        return id
    }

    func removeObserver(id: UUID) {
        observers.removeValue(forKey: id)
    }

    private func fetch() -> BatteryReading {
        let blob = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let list = IOPSCopyPowerSourcesList(blob).takeRetainedValue() as Array
        var percentage = 0
        var isCharging = false
        var isFullyCharged = false
        var timeToEmpty: Int?
        var timeToFull: Int?
        let powerSource = IOPSGetProvidingPowerSourceType(blob).takeRetainedValue() as String

        for ps in list {
            if let info = IOPSGetPowerSourceDescription(blob, ps).takeUnretainedValue() as? [String: Any] {
                if let current = info[kIOPSCurrentCapacityKey as String] as? Int,
                   let max = info[kIOPSMaxCapacityKey as String] as? Int, max > 0 {
                    percentage = Int(Double(current) / Double(max) * 100.0)
                }
                if let charging = info[kIOPSIsChargingKey as String] as? Bool {
                    isCharging = charging
                }
                if let full = info[kIOPSIsChargedKey as String] as? Bool {
                    isFullyCharged = full
                }
                if let tEmpty = info[kIOPSTimeToEmptyKey as String] as? Int, tEmpty >= 0 {
                    timeToEmpty = tEmpty
                }
                if let tFull = info[kIOPSTimeToFullChargeKey as String] as? Int, tFull >= 0 {
                    timeToFull = tFull
                }
            }
        }

        return BatteryReading(percentage: percentage, isCharging: isCharging, isFullyCharged: isFullyCharged, timeToEmpty: timeToEmpty, timeToFullCharge: timeToFull, powerSource: powerSource)
    }

    private func syncToAppGroup(reading: BatteryReading) {
        if let shared = UserDefaults(suiteName: appGroup) {
            shared.set(reading.percentage, forKey: "battery.percentage")
            shared.set(reading.isCharging, forKey: "battery.isCharging")
            shared.set(reading.isFullyCharged, forKey: "battery.isFull")
            shared.set(reading.timeToEmpty ?? -1, forKey: "battery.timeToEmpty")
            shared.set(reading.timeToFullCharge ?? -1, forKey: "battery.timeToFull")
            shared.synchronize()
        }
    }
}

extension BatteryService {
    static let powerChangedCallback: IOPowerSourceCallbackType = { context in
        guard let context else { return }
        let service = Unmanaged<BatteryService>.fromOpaque(context).takeUnretainedValue()
        service.update()
    }
}
