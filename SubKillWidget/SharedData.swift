import Foundation

// Shared data structures for Widget + Main App communication via App Groups
// App Group ID: group.com.klause.SubKill

struct WidgetData: Codable {
    let totalMonthly: Double
    let totalDaily: Double
    let currencySymbol: String
    let activeCount: Int
    let topSubscriptions: [WidgetSubscription]
    let nextRenewal: WidgetSubscription?
    let lastUpdated: Date
}

struct WidgetSubscription: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String
    let price: Double
    let colorHex: String
    let daysUntilRenewal: Int
}

enum SharedDataManager {
    static let suiteName = "group.com.klause.SubKill"

    static func save(_ data: WidgetData) {
        guard let encoded = try? JSONEncoder().encode(data),
              let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.set(encoded, forKey: "widgetData")
    }

    static func load() -> WidgetData? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: "widgetData"),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else { return nil }
        return decoded
    }

    static func placeholder() -> WidgetData {
        WidgetData(
            totalMonthly: 0,
            totalDaily: 0,
            currencySymbol: "$",
            activeCount: 0,
            topSubscriptions: [],
            nextRenewal: nil,
            lastUpdated: .now
        )
    }
}
