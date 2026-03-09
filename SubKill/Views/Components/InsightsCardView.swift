import SwiftUI

struct Insight: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
    let actionLabel: String?
    let savings: Decimal?
}

struct InsightsCardView: View {
    let insights: [Insight]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Smart Insights")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(insights.count)")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.yellow.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.horizontal)

            ForEach(insights) { insight in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(insight.color.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: insight.icon)
                            .font(.body)
                            .foregroundStyle(insight.color)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(insight.title)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)

                        Text(insight.description)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    if let savings = insight.savings {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Save")
                                .font(.caption2)
                                .foregroundStyle(Theme.emerald)
                            Text("$\(NSDecimalNumber(decimal: savings).doubleValue.formatted(.number.precision(.fractionLength(0))))/yr")
                                .font(.system(.caption, design: .monospaced, weight: .bold))
                                .foregroundStyle(Theme.emerald)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Theme.surface)
                )
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Insight Generator

enum InsightGenerator {
    static func generate(from subscriptions: [Subscription]) -> [Insight] {
        let active = subscriptions.filter { $0.isActive }
        guard !active.isEmpty else { return [] }

        var insights: [Insight] = []

        // 1. Most expensive subscription
        if let most = active.max(by: { $0.monthlyPrice < $1.monthlyPrice }),
           most.monthlyPrice > 20 {
            insights.append(Insight(
                icon: "flame.fill",
                title: "\(most.name) is your biggest drain",
                description: "It costs \(most.formattedMonthlyPrice)/mo — \(percentOfTotal(most.monthlyPrice, in: active))% of your total spending.",
                color: Theme.coral,
                actionLabel: "Review",
                savings: most.yearlyPrice
            ))
        }

        // 2. Duplicate category spending
        let grouped = Dictionary(grouping: active) { $0.category }
        for (category, subs) in grouped where subs.count >= 3 {
            let total = subs.reduce(Decimal(0)) { $0 + $1.monthlyPrice }
            insights.append(Insight(
                icon: "square.stack.3d.up.fill",
                title: "\(subs.count) \(category.rawValue) subscriptions",
                description: "You're spending \(formatAmount(total))/mo on \(category.rawValue). Do you need all of them?",
                color: category.color,
                actionLabel: nil,
                savings: total * 4 // assume they can cut 1/3
            ))
        }

        // 3. Streaming overlap
        let streamingSubs = active.filter {
            $0.category == .streaming || $0.category == .entertainment || $0.category == .music
        }
        if streamingSubs.count >= 3 {
            let total = streamingSubs.reduce(Decimal(0)) { $0 + $1.monthlyPrice }
            insights.append(Insight(
                icon: "tv.and.mediabox",
                title: "Streaming overload",
                description: "\(streamingSubs.count) streaming/entertainment subs totaling \(formatAmount(total))/mo. Consider rotating them monthly.",
                color: .purple,
                actionLabel: nil,
                savings: total * 6 // half a year savings if they rotate
            ))
        }

        // 4. Free alternatives available
        let aiSubs = active.filter { $0.category == .ai }
        if aiSubs.count >= 2 {
            let total = aiSubs.reduce(Decimal(0)) { $0 + $1.monthlyPrice }
            insights.append(Insight(
                icon: "brain.head.profile",
                title: "\(aiSubs.count) AI tool subscriptions",
                description: "You spend \(formatAmount(total))/mo on AI tools. Most overlap in features — pick the best one.",
                color: .teal,
                actionLabel: nil,
                savings: total / 2 * 12
            ))
        }

        // 5. Annual billing suggestion
        let monthlyCandidates = active.filter { $0.billingCycle == .monthly && $0.monthlyPrice >= 10 }
        if !monthlyCandidates.isEmpty {
            let potentialSavings = monthlyCandidates.reduce(Decimal(0)) { $0 + $1.monthlyPrice } * Decimal(0.16) * 12
            insights.append(Insight(
                icon: "arrow.triangle.2.circlepath",
                title: "Switch to annual billing",
                description: "\(monthlyCandidates.count) subscriptions could be cheaper yearly (typically 15-20% off).",
                color: Theme.electricCyan,
                actionLabel: nil,
                savings: potentialSavings
            ))
        }

        // 6. Upcoming renewal warning
        let upcoming = active.filter { $0.daysUntilRenewal >= 0 && $0.daysUntilRenewal <= 3 }
        for sub in upcoming {
            insights.append(Insight(
                icon: "exclamationmark.triangle.fill",
                title: "\(sub.name) renews in \(sub.daysUntilRenewal) day\(sub.daysUntilRenewal == 1 ? "" : "s")",
                description: "Cancel before renewal to avoid being charged \(sub.formattedPrice).",
                color: Theme.coral,
                actionLabel: "Cancel",
                savings: sub.yearlyPrice
            ))
        }

        // 7. Total spending milestone
        let totalMonthly = active.reduce(Decimal(0)) { $0 + $1.monthlyPrice }
        if totalMonthly > 100 {
            insights.append(Insight(
                icon: "chart.line.uptrend.xyaxis",
                title: "Spending over \(formatAmount(100))/month",
                description: "Your subscriptions cost \(formatAmount(totalMonthly * 12)) per year. That's a vacation!",
                color: .orange,
                actionLabel: nil,
                savings: nil
            ))
        }

        return Array(insights.prefix(5))
    }

    private static func percentOfTotal(_ amount: Decimal, in subs: [Subscription]) -> Int {
        let total = subs.reduce(Decimal(0)) { $0 + $1.monthlyPrice }
        guard total > 0 else { return 0 }
        return Int(NSDecimalNumber(decimal: amount / total * 100).doubleValue)
    }

    private static func formatAmount(_ amount: Decimal) -> String {
        "$\(NSDecimalNumber(decimal: amount).doubleValue.formatted(.number.precision(.fractionLength(2))))"
    }
}

#Preview {
    ZStack {
        Theme.deepNavy.ignoresSafeArea()
        InsightsCardView(insights: [
            Insight(icon: "flame.fill", title: "Netflix is your biggest drain",
                    description: "It costs $15.49/mo — 32% of your total spending.",
                    color: Theme.coral, actionLabel: "Review", savings: 185.88),
            Insight(icon: "arrow.triangle.2.circlepath", title: "Switch to annual billing",
                    description: "3 subscriptions could be cheaper yearly.",
                    color: Theme.electricCyan, actionLabel: nil, savings: 48)
        ])
    }
}
