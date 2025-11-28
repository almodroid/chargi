import WidgetKit
import SwiftUI

struct ChargiEntry: TimelineEntry {
    let date: Date
    let text: String
    let percentage: Int
    let isCharging: Bool
    let isFull: Bool
}

struct ChargiProvider: TimelineProvider {
    func placeholder(in context: Context) -> ChargiEntry {
        ChargiEntry(date: Date(), text: "--", percentage: 100, isCharging: false, isFull: true)
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
        if !enabled { return ChargiEntry(date: Date(), text: "--", percentage: 0, isCharging: false, isFull: false) }
        let isCharging = defaults?.bool(forKey: "battery.isCharging") ?? false
        let isFull = defaults?.bool(forKey: "battery.isFull") ?? false
        let percentage = defaults?.integer(forKey: "battery.percentage") ?? 0
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
        return ChargiEntry(date: Date(), text: text, percentage: percentage, isCharging: isCharging, isFull: isFull)
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
    @Environment(\.widgetFamily) var family
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidget(entry: entry)
        case .systemMedium:
            MediumWidget(entry: entry)
        case .systemLarge:
            LargeWidget(entry: entry)
        default:
            SmallWidget(entry: entry)
        }
    }
}

struct SmallWidget: View {
    var entry: ChargiProvider.Entry
    var body: some View {
        ZStack {
            LinearGradient(colors: backgroundColors(entry: entry), startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: entry.isFull ? "battery.100" : "battery.100")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.white.opacity(0.9))
                    if entry.isCharging {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                    }
                }
                Text("\(entry.percentage)%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text(entry.isFull ? "Full" : entry.isCharging ? "Charging" : "On battery")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text(entry.text)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(10)
        }
    }
}

struct MediumWidget: View {
    var entry: ChargiProvider.Entry
    var body: some View {
        ZStack {
            LinearGradient(colors: backgroundColors(entry: entry), startPoint: .topLeading, endPoint: .bottomTrailing)
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 10)
                        .frame(width: 60, height: 60)
                    Circle()
                        .trim(from: 0, to: CGFloat(min(max(Double(entry.percentage) / 100.0, 0), 1)))
                        .stroke(AngularGradient(colors: ringColors(entry: entry), center: .center), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 60, height: 60)
                    if entry.isCharging {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                            .offset(y: 22)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.percentage)%")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text(entry.isFull ? "Full" : entry.isCharging ? "Charging" : "On battery")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    Text(entry.text)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
            }
            .padding(12)
        }
    }
}

func backgroundColors(entry: ChargiProvider.Entry) -> [Color] {
    if entry.isFull { return [Color.green.opacity(0.8), Color.green] }
    if entry.isCharging { return [Color.green.opacity(0.6), Color.blue] }
    if entry.percentage <= 20 { return [Color.red.opacity(0.7), Color.orange] }
    return [Color.blue.opacity(0.6), Color.indigo]
}

func ringColors(entry: ChargiProvider.Entry) -> [Color] {
    if entry.isFull { return [Color.green, Color.green] }
    if entry.isCharging { return [Color.green, Color.blue] }
    if entry.percentage <= 20 { return [Color.red, Color.orange] }
    return [Color.blue, Color.indigo]
}

struct LargeWidget: View {
    var entry: ChargiProvider.Entry
    var body: some View {
        ZStack {
            LinearGradient(colors: backgroundColors(entry: entry), startPoint: .topLeading, endPoint: .bottomTrailing)
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 14)
                        .frame(width: 100, height: 100)
                    Circle()
                        .trim(from: 0, to: CGFloat(min(max(Double(entry.percentage) / 100.0, 0), 1)))
                        .stroke(AngularGradient(colors: ringColors(entry: entry), center: .center), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 100, height: 100)
                    VStack(spacing: 4) {
                        Text("\(entry.percentage)%")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        if entry.isCharging {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.isFull ? "Full" : entry.isCharging ? "Charging" : "On battery")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Time: \(entry.text)")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Status updates every minute")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(16)
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("Chargi")
        .description("Battery time remaining")
    }
}
