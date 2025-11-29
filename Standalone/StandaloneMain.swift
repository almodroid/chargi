import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let statusBar = StatusBarController()
    let batteryService = BatteryService()
    let bubbleController = BubbleController()
    let preferences = Preferences()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let cwd = FileManager.default.currentDirectoryPath
        let icnsPath = cwd + "/Resources/AppIcon.icns"
        if let img = NSImage(contentsOfFile: icnsPath) {
            NSApp.applicationIconImage = img
        } else {
            NSApp.applicationIconImage = IconFactory.dockChargiIcon()
        }
        batteryService.start()
        bubbleController.bind(batteryService: batteryService, preferences: preferences)
        statusBar.setup(batteryService: batteryService, bubbleController: bubbleController, preferences: preferences)
        preferences.syncToAppGroup()
        if preferences.showFloatingBubble {
            bubbleController.show()
        }
        handleFirstRunBehaviors()
    }

    private func handleFirstRunBehaviors() {
        let appPath = Bundle.main.bundlePath
        let appName = (appPath as NSString).lastPathComponent
        let sysApps = "/Applications"
        let userApps = (NSHomeDirectory() as NSString).appendingPathComponent("Applications")
        let inApplications = appPath.hasPrefix(sysApps + "/") || appPath.hasPrefix(userApps + "/")
        if !inApplications {
            if !preferences.promptedMoveToApplications {
                let alert = NSAlert()
                alert.messageText = "Move to Applications?"
                alert.informativeText = "Move Chargi to the Applications folder?"
                alert.addButton(withTitle: "Move")
                alert.addButton(withTitle: "Not Now")
                let response = alert.runModal()
                preferences.promptedMoveToApplications = true
                if response == .alertFirstButtonReturn {
                    let destSys = URL(fileURLWithPath: sysApps).appendingPathComponent(appName)
                    let destUser = URL(fileURLWithPath: userApps).appendingPathComponent(appName)
                    let fm = FileManager.default
                    var dest = destSys
                    if !(fm.isWritableFile(atPath: sysApps)) { dest = destUser }
                    try? fm.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
                    if fm.fileExists(atPath: dest.path) { try? fm.removeItem(at: dest) }
                    do {
                        try fm.copyItem(at: URL(fileURLWithPath: appPath), to: dest)
                        NSWorkspace.shared.open(dest)
                        NSApplication.shared.terminate(nil)
                        return
                    } catch {}
                }
            }
        }
        if !preferences.launchAtLogin {
            let alert = NSAlert()
            alert.messageText = "Launch at Login?"
            alert.informativeText = "Launch Chargi at startup?"
            alert.addButton(withTitle: "Enable")
            alert.addButton(withTitle: "Not Now")
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                preferences.launchAtLogin = true
                installLaunchAgent()
            }
        }
    }

    private func installLaunchAgent() {
        let label = "app.chargi"
        let fm = FileManager.default
        let agentsDir = (NSHomeDirectory() as NSString).appendingPathComponent("Library/LaunchAgents")
        let execName = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String ?? "Chargi"
        let execPath = (Bundle.main.bundlePath as NSString).appendingPathComponent("Contents/MacOS/\(execName)")
        let plistURL = URL(fileURLWithPath: agentsDir).appendingPathComponent("\(label).plist")
        let dict: [String: Any] = [
            "Label": label,
            "ProgramArguments": [execPath],
            "RunAtLoad": true
        ]
        let data = try? PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
        try? fm.createDirectory(atPath: agentsDir, withIntermediateDirectories: true)
        if let d = data { try? d.write(to: plistURL) }
        let p = Process()
        p.launchPath = "/bin/launchctl"
        p.arguments = ["bootstrap", "gui/\(getuid())", plistURL.path]
        try? p.run()
    }
}
