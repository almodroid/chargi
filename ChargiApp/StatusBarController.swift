import AppKit

final class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var batteryService: BatteryService?
    private var bubbleController: BubbleController?
    private var preferences: Preferences?
    private var observerId: UUID?
    private var pulseTimer: Timer?
    private var pulsePhase: CGFloat = 0

    func setup(batteryService: BatteryService, bubbleController: BubbleController, preferences: Preferences) {
        self.batteryService = batteryService
        self.bubbleController = bubbleController
        self.preferences = preferences
        configureMenu()
        configureUpdates()
    }

    private func configureUpdates() {
        observerId = batteryService?.addObserver { [weak self] reading in
            self?.updateStatus(reading: reading)
        }
    }

    private func updateStatus(reading: BatteryReading) {
        guard let button = statusItem.button else { return }
        if preferences?.showMenuBarTime == true {
            button.title = reading.menuBarText
            button.imagePosition = .imageLeading
            if reading.isCharging {
                startPulse()
            } else {
                stopPulse()
                button.image = IconFactory.batteryIcon()
            }
        } else {
            button.title = ""
            if reading.isCharging {
                startPulse()
            } else {
                stopPulse()
                button.image = IconFactory.batteryIcon()
            }
        }
    }

    private func startPulse() {
        guard pulseTimer == nil else { return }
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.pulsePhase += 0.15
            self.statusItem.button?.image = IconFactory.batteryIconPulse(phase: self.pulsePhase)
        }
    }

    private func stopPulse() {
        pulseTimer?.invalidate()
        pulseTimer = nil
        pulsePhase = 0
    }

    private func configureMenu() {
        let menu = NSMenu()

        let bubbleItem = NSMenuItem(title: "Floating Bubble", action: #selector(toggleBubble), keyEquivalent: "")
        bubbleItem.target = self
        bubbleItem.state = preferences?.showFloatingBubble == true ? .on : .off
        menu.addItem(bubbleItem)

        let widgetItem = NSMenuItem(title: "Widget Content", action: #selector(toggleWidget), keyEquivalent: "")
        widgetItem.target = self
        widgetItem.state = preferences?.enableWidgetContent == true ? .on : .off
        menu.addItem(widgetItem)

        let menuBarTimeItem = NSMenuItem(title: "Show Time In Menu Bar", action: #selector(toggleMenuBarTime), keyEquivalent: "")
        menuBarTimeItem.target = self
        menuBarTimeItem.state = preferences?.showMenuBarTime == true ? .on : .off
        menu.addItem(menuBarTimeItem)

        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func toggleBubble() {
        guard let preferences else { return }
        preferences.showFloatingBubble.toggle()
        statusItem.menu?.item(at: 0)?.state = preferences.showFloatingBubble ? .on : .off
        if preferences.showFloatingBubble {
            bubbleController?.show()
        } else {
            bubbleController?.hide()
        }
    }

    @objc private func toggleWidget() {
        guard let preferences else { return }
        preferences.enableWidgetContent.toggle()
        statusItem.menu?.item(at: 1)?.state = preferences.enableWidgetContent ? .on : .off
    }

    @objc private func toggleMenuBarTime() {
        guard let preferences else { return }
        preferences.showMenuBarTime.toggle()
        statusItem.menu?.item(at: 2)?.state = preferences.showMenuBarTime ? .on : .off
        if let reading = batteryService?.latest {
            updateStatus(reading: reading)
        }
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
