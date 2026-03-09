import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct SubKillProvider: TimelineProvider {
    func placeholder(in context: Context) -> SubKillEntry {
        SubKillEntry(date: .now, data: SharedDataManager.placeholder())
    }

    func getSnapshot(in context: Context, completion: @escaping (SubKillEntry) -> Void) {
        let data = SharedDataManager.load() ?? SharedDataManager.placeholder()
        completion(SubKillEntry(date: .now, data: data))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SubKillEntry>) -> Void) {
        let data = SharedDataManager.load() ?? SharedDataManager.placeholder()
        let entry = SubKillEntry(date: .now, data: data)
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct SubKillEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Widget Views

struct SubKillWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: SubKillEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(data: entry.data)
        case .systemMedium:
            MediumWidgetView(data: entry.data)
        case .systemLarge:
            LargeWidgetView(data: entry.data)
        default:
            SmallWidgetView(data: entry.data)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let data: WidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "00D4FF"))
                Text("SubKill")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Text(formatCurrency(data.totalMonthly))
                .font(.system(.title, design: .monospaced, weight: .bold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text("per month")
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))

            HStack(spacing: 4) {
                Text("\(data.activeCount)")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(Color(hex: "00D4FF"))
                Text("active")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()

                Text(formatCurrency(data.totalDaily) + "/day")
                    .font(.system(.caption2, design: .monospaced, weight: .semibold))
                    .foregroundStyle(Color(hex: "FF6B6B"))
            }
        }
        .padding(2)
    }

    private func formatCurrency(_ amount: Double) -> String {
        "\(data.currencySymbol)\(amount.formatted(.number.precision(.fractionLength(2))))"
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let data: WidgetData

    var body: some View {
        HStack(spacing: 16) {
            // Left side - totals
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "00D4FF"))
                    Text("SubKill")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                Text(formatCurrency(data.totalMonthly))
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text("per month")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))

                HStack(spacing: 8) {
                    Label("\(data.activeCount)", systemImage: "creditcard")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(Color(hex: "00D4FF"))

                    Text(formatCurrency(data.totalDaily) + "/day")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(Color(hex: "FF6B6B"))
                }
            }

            // Divider
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(width: 1)

            // Right side - top subscriptions
            VStack(alignment: .leading, spacing: 6) {
                Text("Top Drains")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))

                if data.topSubscriptions.isEmpty {
                    Text("No subscriptions yet")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                } else {
                    ForEach(data.topSubscriptions.prefix(3)) { sub in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(hex: sub.colorHex))
                                .frame(width: 8, height: 8)
                            Text(sub.name)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Spacer()
                            Text(formatCurrency(sub.price))
                                .font(.system(.caption2, design: .monospaced, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }

                Spacer()
            }
        }
        .padding(2)
    }

    private func formatCurrency(_ amount: Double) -> String {
        "\(data.currencySymbol)\(amount.formatted(.number.precision(.fractionLength(2))))"
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let data: WidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(Color(hex: "00D4FF"))
                Text("SubKill")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(data.activeCount) active")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }

            // Total
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formatCurrency(data.totalMonthly))
                    .font(.system(.title, design: .monospaced, weight: .bold))
                    .foregroundStyle(.white)
                Text("/mo")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Text(formatCurrency(data.totalDaily) + "/day")
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundStyle(Color(hex: "FF6B6B"))
            }

            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(height: 1)

            // Next Renewal
            if let next = data.nextRenewal {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: next.colorHex).opacity(0.2))
                            .frame(width: 32, height: 32)
                        Image(systemName: next.icon)
                            .font(.caption)
                            .foregroundStyle(Color(hex: next.colorHex))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next Renewal")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("\(next.name) — \(next.daysUntilRenewal)d")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(next.daysUntilRenewal <= 3 ? Color(hex: "FF6B6B") : .white)
                    }

                    Spacer()

                    Text(formatCurrency(next.price))
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.05))
                )
            }

            // Top Drains
            Text("Top Drains")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 2)

            if data.topSubscriptions.isEmpty {
                Text("Add subscriptions to see your top drains")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
            } else {
                ForEach(Array(data.topSubscriptions.prefix(3).enumerated()), id: \.element.id) { index, sub in
                    HStack(spacing: 10) {
                        Text("#\(index + 1)")
                            .font(.system(.caption2, design: .monospaced, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                            .frame(width: 18)

                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: sub.colorHex).opacity(0.2))
                                .frame(width: 26, height: 26)
                            Image(systemName: sub.icon)
                                .font(.system(size: 11))
                                .foregroundStyle(Color(hex: sub.colorHex))
                        }

                        Text(sub.name)
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 1) {
                            Text(formatCurrency(sub.price) + "/mo")
                                .font(.system(.caption2, design: .monospaced, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                            if sub.daysUntilRenewal <= 7 {
                                Text("\(sub.daysUntilRenewal)d")
                                    .font(.system(.caption2, design: .rounded, weight: .bold))
                                    .foregroundStyle(sub.daysUntilRenewal <= 3 ? Color(hex: "FF6B6B") : Color(hex: "00D4FF"))
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(2)
    }

    private func formatCurrency(_ amount: Double) -> String {
        "\(data.currencySymbol)\(amount.formatted(.number.precision(.fractionLength(2))))"
    }
}

// MARK: - Widget Configuration

struct SubKillWidget: Widget {
    let kind: String = "SubKillWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubKillProvider()) { entry in
            SubKillWidgetEntryView(entry: entry)
                .containerBackground(Color(hex: "0A1628"), for: .widget)
        }
        .configurationDisplayName("SubKill")
        .description("Track your subscription spending at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    SubKillWidget()
} timeline: {
    SubKillEntry(date: .now, data: WidgetData(
        totalMonthly: 89.97, totalDaily: 2.96, currencySymbol: "$",
        activeCount: 7,
        topSubscriptions: [],
        nextRenewal: nil, lastUpdated: .now
    ))
}

#Preview(as: .systemMedium) {
    SubKillWidget()
} timeline: {
    SubKillEntry(date: .now, data: WidgetData(
        totalMonthly: 89.97, totalDaily: 2.96, currencySymbol: "$",
        activeCount: 7,
        topSubscriptions: [
            WidgetSubscription(id: "1", name: "Netflix", icon: "play.tv", price: 15.49, colorHex: "E50914", daysUntilRenewal: 3),
            WidgetSubscription(id: "2", name: "Spotify", icon: "music.note", price: 9.99, colorHex: "1DB954", daysUntilRenewal: 12),
            WidgetSubscription(id: "3", name: "ChatGPT", icon: "brain.head.profile", price: 20.00, colorHex: "10A37F", daysUntilRenewal: 8)
        ],
        nextRenewal: WidgetSubscription(id: "1", name: "Netflix", icon: "play.tv", price: 15.49, colorHex: "E50914", daysUntilRenewal: 3),
        lastUpdated: .now
    ))
}

#Preview(as: .systemLarge) {
    SubKillWidget()
} timeline: {
    SubKillEntry(date: .now, data: WidgetData(
        totalMonthly: 89.97, totalDaily: 2.96, currencySymbol: "$",
        activeCount: 7,
        topSubscriptions: [
            WidgetSubscription(id: "1", name: "Netflix", icon: "play.tv", price: 15.49, colorHex: "E50914", daysUntilRenewal: 3),
            WidgetSubscription(id: "2", name: "ChatGPT Plus", icon: "brain.head.profile", price: 20.00, colorHex: "10A37F", daysUntilRenewal: 8),
            WidgetSubscription(id: "3", name: "Spotify", icon: "music.note", price: 9.99, colorHex: "1DB954", daysUntilRenewal: 12)
        ],
        nextRenewal: WidgetSubscription(id: "1", name: "Netflix", icon: "play.tv", price: 15.49, colorHex: "E50914", daysUntilRenewal: 3),
        lastUpdated: .now
    ))
}
