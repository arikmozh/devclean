import SwiftUI
import SwiftData
import Foundation

// MARK: - Billing Cycle

enum BillingCycle: String, Codable, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiAnnual = "Semi-Annual"
    case yearly = "Yearly"

    var id: String { rawValue }

    var monthlyMultiplier: Decimal {
        switch self {
        case .weekly: return 52 / 12
        case .monthly: return 1
        case .quarterly: return Decimal(1) / 3
        case .semiAnnual: return Decimal(1) / 6
        case .yearly: return Decimal(1) / 12
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .weekly: return .weekOfYear
        case .monthly: return .month
        case .quarterly: return .month
        case .semiAnnual: return .month
        case .yearly: return .year
        }
    }

    var calendarValue: Int {
        switch self {
        case .weekly: return 1
        case .monthly: return 1
        case .quarterly: return 3
        case .semiAnnual: return 6
        case .yearly: return 1
        }
    }

    var displayShort: String {
        switch self {
        case .weekly: return "/wk"
        case .monthly: return "/mo"
        case .quarterly: return "/3mo"
        case .semiAnnual: return "/6mo"
        case .yearly: return "/yr"
        }
    }
}

// MARK: - Category

enum SubCategory: String, Codable, CaseIterable, Identifiable {
    case entertainment = "Entertainment"
    case music = "Music"
    case streaming = "Streaming"
    case productivity = "Productivity"
    case health = "Health"
    case gaming = "Gaming"
    case cloud = "Cloud Storage"
    case news = "News"
    case education = "Education"
    case social = "Social"
    case finance = "Finance"
    case ai = "AI Tools"
    case vpn = "VPN"
    case fitness = "Fitness"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .entertainment: return "tv"
        case .music: return "music.note"
        case .streaming: return "play.rectangle"
        case .productivity: return "hammer"
        case .health: return "heart"
        case .gaming: return "gamecontroller"
        case .cloud: return "cloud"
        case .news: return "newspaper"
        case .education: return "graduationcap"
        case .social: return "person.2"
        case .finance: return "banknote"
        case .ai: return "brain.head.profile"
        case .vpn: return "lock.shield"
        case .fitness: return "figure.run"
        case .other: return "ellipsis.circle"
        }
    }

    var color: Color {
        switch self {
        case .entertainment: return .purple
        case .music: return .pink
        case .streaming: return .red
        case .productivity: return .blue
        case .health: return .green
        case .gaming: return .orange
        case .cloud: return .cyan
        case .news: return .gray
        case .education: return .yellow
        case .social: return .indigo
        case .finance: return .mint
        case .ai: return .teal
        case .vpn: return .brown
        case .fitness: return Color(hex: "00E676")
        case .other: return .secondary
        }
    }
}

// MARK: - Currency

enum AppCurrency: String, Codable, CaseIterable, Identifiable {
    case usd = "USD"
    case ils = "ILS"
    case eur = "EUR"
    case gbp = "GBP"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .usd: return "$"
        case .ils: return "₪"
        case .eur: return "€"
        case .gbp: return "£"
        }
    }
}

// MARK: - Subscription Model

@Model
final class Subscription {
    var id: UUID
    var name: String
    var icon: String
    var price: Decimal
    var currency: AppCurrency
    var billingCycle: BillingCycle
    var category: SubCategory
    var startDate: Date
    var nextRenewalDate: Date
    var reminderDaysBefore: Int
    var isActive: Bool
    var cancelledDate: Date?
    var colorHex: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    init(
        name: String,
        icon: String = "creditcard",
        price: Decimal,
        currency: AppCurrency = .usd,
        billingCycle: BillingCycle = .monthly,
        category: SubCategory = .other,
        startDate: Date = .now,
        nextRenewalDate: Date = .now,
        reminderDaysBefore: Int = 2,
        colorHex: String = "00D4FF",
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.price = price
        self.currency = currency
        self.billingCycle = billingCycle
        self.category = category
        self.startDate = startDate
        self.nextRenewalDate = nextRenewalDate
        self.reminderDaysBefore = reminderDaysBefore
        self.isActive = true
        self.cancelledDate = nil
        self.colorHex = colorHex
        self.notes = notes
        self.createdAt = .now
        self.updatedAt = .now
    }

    // MARK: - Computed Properties

    var monthlyPrice: Decimal {
        price * billingCycle.monthlyMultiplier
    }

    var yearlyPrice: Decimal {
        monthlyPrice * 12
    }

    var dailyPrice: Decimal {
        yearlyPrice / 365
    }

    var color: Color {
        Color(hex: colorHex)
    }

    var daysUntilRenewal: Int {
        Calendar.current.dateComponents([.day], from: .now, to: nextRenewalDate).day ?? 0
    }

    var isRenewingSoon: Bool {
        daysUntilRenewal <= reminderDaysBefore && daysUntilRenewal >= 0
    }

    var formattedPrice: String {
        "\(currency.symbol)\(NSDecimalNumber(decimal: price).doubleValue.formatted(.number.precision(.fractionLength(2))))"
    }

    var formattedMonthlyPrice: String {
        "\(currency.symbol)\(NSDecimalNumber(decimal: monthlyPrice).doubleValue.formatted(.number.precision(.fractionLength(2))))"
    }

    // MARK: - Methods

    func cancel() {
        isActive = false
        cancelledDate = .now
        updatedAt = .now
    }

    func reactivate() {
        isActive = true
        cancelledDate = nil
        updatedAt = .now
    }

    func advanceRenewalDate() {
        let calendar = Calendar.current
        nextRenewalDate = calendar.date(
            byAdding: billingCycle.calendarComponent,
            value: billingCycle.calendarValue,
            to: nextRenewalDate
        ) ?? nextRenewalDate
        updatedAt = .now
    }
}
