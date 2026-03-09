import SwiftUI
import SwiftData

@Observable
final class DashboardViewModel {
    var subscriptions: [Subscription] = []
    var showingAddSheet = false
    var showingCancelConfirm = false
    var subscriptionToCancel: Subscription?
    var showingSavedAnimation = false
    var lastSavedAmount: Decimal = 0
    var searchText = ""
    var selectedCategory: SubCategory?
    var sortOption: SortOption = .nextRenewal

    enum SortOption: String, CaseIterable {
        case nextRenewal = "Next Renewal"
        case priceHighToLow = "Price: High → Low"
        case priceLowToHigh = "Price: Low → High"
        case name = "Name A-Z"
        case newest = "Newest First"
    }

    // MARK: - Computed

    var activeSubscriptions: [Subscription] {
        subscriptions.filter { $0.isActive }
    }

    var cancelledSubscriptions: [Subscription] {
        subscriptions.filter { !$0.isActive }
    }

    var filteredSubscriptions: [Subscription] {
        var result = activeSubscriptions
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        switch sortOption {
        case .nextRenewal:
            return result.sorted { $0.nextRenewalDate < $1.nextRenewalDate }
        case .priceHighToLow:
            return result.sorted { $0.monthlyPrice > $1.monthlyPrice }
        case .priceLowToHigh:
            return result.sorted { $0.monthlyPrice < $1.monthlyPrice }
        case .name:
            return result.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .newest:
            return result.sorted { $0.createdAt > $1.createdAt }
        }
    }

    var totalMonthly: Decimal {
        activeSubscriptions.reduce(0) { $0 + $1.monthlyPrice }
    }

    var totalYearly: Decimal {
        totalMonthly * 12
    }

    var totalDaily: Decimal {
        totalYearly / 365
    }

    var totalSaved: Decimal {
        cancelledSubscriptions.reduce(0) { total, sub in
            guard let cancelDate = sub.cancelledDate else { return total }
            let monthsSinceCancelled = Calendar.current.dateComponents(
                [.month], from: cancelDate, to: .now
            ).month ?? 0
            return total + (sub.monthlyPrice * Decimal(max(monthsSinceCancelled, 1)))
        }
    }

    var categoryBreakdown: [(category: SubCategory, amount: Decimal, percentage: Double)] {
        let grouped = Dictionary(grouping: activeSubscriptions) { $0.category }
        let total = NSDecimalNumber(decimal: totalMonthly).doubleValue

        return grouped.map { category, subs in
            let amount = subs.reduce(Decimal(0)) { $0 + $1.monthlyPrice }
            let pct = total > 0 ? NSDecimalNumber(decimal: amount).doubleValue / total * 100 : 0
            return (category, amount, pct)
        }.sorted { $0.amount > $1.amount }
    }

    var upcomingRenewals: [Subscription] {
        activeSubscriptions
            .filter { $0.daysUntilRenewal >= 0 && $0.daysUntilRenewal <= 7 }
            .sorted { $0.nextRenewalDate < $1.nextRenewalDate }
    }

    var drainRate: Double {
        // 0.0 to 1.0 based on how many subscriptions relative to a "full tank"
        let count = Double(activeSubscriptions.count)
        return min(count / 20.0, 1.0) // 20 subs = full drain
    }

    // MARK: - Formatting

    func formatCurrency(_ amount: Decimal, currency: AppCurrency = .usd) -> String {
        "\(currency.symbol)\(NSDecimalNumber(decimal: amount).doubleValue.formatted(.number.precision(.fractionLength(2))))"
    }

    var primaryCurrency: AppCurrency {
        // Most used currency across subscriptions
        let currencies = activeSubscriptions.map { $0.currency }
        let counted = Dictionary(grouping: currencies) { $0 }.mapValues { $0.count }
        return counted.max(by: { $0.value < $1.value })?.key ?? .usd
    }

    // MARK: - Actions

    func confirmCancel(_ subscription: Subscription) {
        subscriptionToCancel = subscription
        showingCancelConfirm = true
    }

    func performCancel() {
        guard let sub = subscriptionToCancel else { return }
        lastSavedAmount = sub.monthlyPrice * 12
        sub.cancel()
        showingSavedAnimation = true
        subscriptionToCancel = nil
    }
}
