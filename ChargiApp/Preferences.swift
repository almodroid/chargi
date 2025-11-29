import Foundation

final class Preferences {
    private let defaults = UserDefaults.standard
    private let showBubbleKey = "pref.showFloatingBubble"
    private let enableWidgetKey = "pref.enableWidgetContent"
    private let showMenuBarTimeKey = "pref.showMenuBarTime"
    private let promptedMoveKey = "pref.promptedMoveToApplications"
    private let launchAtLoginKey = "pref.launchAtLogin"
    private let appGroup = "group.chargi.app"

    var showFloatingBubble: Bool {
        get { defaults.object(forKey: showBubbleKey) as? Bool ?? false }
        set { defaults.set(newValue, forKey: showBubbleKey); syncToAppGroup() }
    }

    var enableWidgetContent: Bool {
        get { defaults.object(forKey: enableWidgetKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: enableWidgetKey); syncToAppGroup() }
    }

    var showMenuBarTime: Bool {
        get { defaults.object(forKey: showMenuBarTimeKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: showMenuBarTimeKey) }
    }

    var promptedMoveToApplications: Bool {
        get { defaults.object(forKey: promptedMoveKey) as? Bool ?? false }
        set { defaults.set(newValue, forKey: promptedMoveKey) }
    }

    var launchAtLogin: Bool {
        get { defaults.object(forKey: launchAtLoginKey) as? Bool ?? false }
        set { defaults.set(newValue, forKey: launchAtLoginKey) }
    }

    func syncToAppGroup() {
        if let shared = UserDefaults(suiteName: appGroup) {
            shared.set(showFloatingBubble, forKey: showBubbleKey)
            shared.set(enableWidgetContent, forKey: enableWidgetKey)
            shared.synchronize()
        }
    }
}
