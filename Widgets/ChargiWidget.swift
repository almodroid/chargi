import WidgetKit
import SwiftUI

struct ChargiEntry: TimelineEntry {
    let date: Date
    let text: String
}

struct ChargiProvider: TimelineProvider {
    func placeholder(in context: Context) -> ChargiEntry {
        ChargiEntry(date: Date(), text: "--")
    }

    func getSnapshot(in context: Context, completion: @escaping (ChargiEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ChargiEntry>) -> Void) {
        let entry = makeEntry()
        let next = Date().addingTimeInterval(60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func makeEntry() -> ChargiEntry {
        let defaults = UserDefaults(suiteName: "group.chargi.app")
        let enabled = defaults?.bool(forKey: "pref.enableWidgetContent") ?? true
        if !enabled { return ChargiEntry(date: Date(), text: "--") }
        let isCharging = defaults?.bool(forKey: "battery.isCharging") ?? false
        let isFull = defaults?.bool(forKey: "battery.isFull") ?? false
        let tEmpty = defaults?.integer(forKey: "battery.timeToEmpty") ?? -1
        let tFull = defaults?.integer(forKey: "battery.timeToFull") ?? -1
        let text: String
        if isFull {
            text = "Full"
        } else if isCharging, tFull >= 0 {
            text = format(minutes: tFull)
        } else if !isCharging, tEmpty >= 0 {
            text = format(minutes: tEmpty)
        } else {
            text = "--"
        }
        return ChargiEntry(date: Date(), text: text)
    }

    private func format(minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 { return String(format: "%dh %dm", h, m) }
        return String(format: "%dm", m)
    }
}

struct ChargiWidgetView: View {
    var entry: ChargiProvider.Entry
    var body: some View {
        ZStack {
            Color.black
            Text(entry.text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

@main
struct ChargiWidget: Widget {
    let kind: String = "ChargiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ChargiProvider()) { entry in
            ChargiWidgetView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Chargi")
        .description("Battery time remaining")
    }
}

