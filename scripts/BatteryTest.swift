import Foundation
import IOKit.ps

func fetch() -> (isCharging: Bool, isFull: Bool, tEmpty: Int, tFull: Int) {
    let blob = IOPSCopyPowerSourcesInfo().takeRetainedValue()
    let list = IOPSCopyPowerSourcesList(blob).takeRetainedValue() as Array
    var isCharging = false
    var isFull = false
    var tEmpty = -1
    var tFull = -1
    for ps in list {
        if let info = IOPSGetPowerSourceDescription(blob, ps).takeUnretainedValue() as? [String: Any] {
            if let c = info[kIOPSIsChargingKey as String] as? Bool { isCharging = c }
            if let f = info[kIOPSIsChargedKey as String] as? Bool { isFull = f }
            if let te = info[kIOPSTimeToEmptyKey as String] as? Int { tEmpty = te }
            if let tf = info[kIOPSTimeToFullChargeKey as String] as? Int { tFull = tf }
        }
    }
    return (isCharging, isFull, tEmpty, tFull)
}

let result = fetch()
print("isCharging=\(result.isCharging) isFull=\(result.isFull) timeToEmpty=\(result.tEmpty) timeToFull=\(result.tFull)")
