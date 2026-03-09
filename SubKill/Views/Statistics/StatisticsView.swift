import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(sort: \Subscription.createdAt) private var allSubscriptions: [Subscription]

    private var active: [Subscription] {
        allSubscriptions.filter { $0.isActive }
    }

    private var cancelled: [Subscription] {
        allSubscriptions.filter { !$0.isActive }
    }

    private var totalMonthly: Decimal {
        active.reduce(0) { $0 + $1.monthlyPrice }
    }

    private var totalYearly: Decimal {
        totalMonthly * 12
    }

    private var totalSaved: Decimal {
        cancelled.reduce(0) { total, sub in
            guard let cancelDate = sub.cancelledDate else { return total }
            let months = Calendar.current.dateComponents([.month], from: cancelDate, to: .now).month ?? 0
            return total + (sub.monthlyPrice * Decimal(max(months, 1)))
        }
    }

    private var categoryData: [(SubCategory, Decimal)] {
        let grouped = Dictionary(grouping: active) { $0.category }
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.monthlyPrice }) }
            .sorted { $0.1 > $1.1 }
    }

    private var mostExpensive: Subscription? {
        active.max { $0.monthlyPrice < $1.monthlyPrice }
    }

    private var cheapest: Subscription? {
        active.min { $0.monthlyPrice < $1.monthlyPrice }
    }

    var body: some View {
        ZStack {
            Theme.deepNavy.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Overview Cards
                    overviewCards

                    // Category Chart
                    if !categoryData.isEmpty {
                        categoryChart
                    }

                    // Top Subscriptions
                    if !active.isEmpty {
                        topSubscriptions
                    }

                    // Fun Facts
                    funFacts

                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Overview

    private var overviewCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Monthly",
                value: formatCurrency(totalMonthly),
                icon: "calendar",
                color: Theme.electricCyan
            )
            StatCard(
                title: "Yearly",
                value: formatCurrency(totalYearly),
                icon: "calendar.badge.clock",
                color: Theme.coral
            )
            StatCard(
                title: "Active",
                value: "\(active.count)",
                icon: "creditcard",
                color: .purple
            )
            StatCard(
                title: "Saved",
                value: formatCurrency(totalSaved),
                icon: "leaf",
                color: Theme.emerald
            )
        }
    }

    // MARK: - Category Chart

    private var categoryChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("By Category")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Chart {
                ForEach(categoryData, id: \.0) { category, amount in
                    SectorMark(
                        angle: .value("Amount", NSDecimalNumber(decimal: amount).doubleValue),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(category.color)
                    .cornerRadius(4)
                }
            }
            .frame(height: 200)
            .chartBackground { _ in
                VStack {
                    Text("\(categoryData.count)")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("categories")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            // Legend
            ForEach(categoryData, id: \.0) { category, amount in
                HStack(spacing: 10) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 10, height: 10)

                    Text(category.rawValue)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    Spacer()

                    Text(formatCurrency(amount))
                        .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.surface)
        )
    }

    // MARK: - Top Subscriptions

    private var topSubscriptions: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Most Expensive")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            let sorted = active.sorted { $0.monthlyPrice > $1.monthlyPrice }

            ForEach(Array(sorted.prefix(5).enumerated()), id: \.element.id) { index, sub in
                HStack(spacing: 12) {
                    Text("#\(index + 1)")
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(Theme.textMuted)
                        .frame(width: 24)

                    Image(systemName: sub.icon)
                        .foregroundStyle(sub.color)
                        .frame(width: 24)

                    Text(sub.name)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)

                    Spacer()

                    Text(sub.formattedMonthlyPrice + "/mo")
                        .font(.system(.subheadline, design: .monospaced, weight: .bold))
                        .foregroundStyle(index == 0 ? Theme.coral : Theme.textSecondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.surface)
        )
    }

    // MARK: - Fun Facts

    private var funFacts: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Perspective")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            let yearly = NSDecimalNumber(decimal: totalYearly).doubleValue

            VStack(spacing: 10) {
                funFactRow("☕️", "That's \(Int(yearly / 5)) coffees per year")
                funFactRow("🍕", "Or \(Int(yearly / 15)) pizza nights")
                funFactRow("✈️", "Or \(Int(yearly / 300)) weekend trips")
                funFactRow("📱", "Or \(Int(yearly / 999)) new iPhones")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.surface)
        )
    }

    private func funFactRow(_ emoji: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.title3)
            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let symbol = active.first?.currency.symbol ?? "$"
        return "\(symbol)\(NSDecimalNumber(decimal: amount).doubleValue.formatted(.number.precision(.fractionLength(2))))"
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.system(.title2, design: .monospaced, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.surface)
        )
    }
}

#Preview {
    NavigationStack {
        StatisticsView()
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}
