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
    }
}
