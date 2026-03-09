import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Bindable var subscription: Subscription
    @Environment(\.dismiss) private var dismiss
    @State private var haptics = HapticService()
    @State private var showEditSheet = false

    var body: some View {
        ZStack {
            Theme.deepNavy.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerCard
                    priceBreakdown
                    renewalInfo

                    if !subscription.notes.isEmpty {
                        notesSection
                    }

                    actionsSection

                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    haptics.lightTap()
                    showEditSheet = true
                } label: {
                    Image(systemName: "pencil.circle")
                        .foregroundStyle(Theme.electricCyan)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditSubscriptionView(subscription: subscription)
        }
    }

    private var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(subscription.color.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: subscription.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(subscription.color)
            }

            Text(subscription.name)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 4) {
                Image(systemName: subscription.category.icon)
                    .font(.caption)
                Text(subscription.category.rawValue)
                    .font(.system(.caption, design: .rounded, weight: .medium))
            }
            .foregroundStyle(subscription.category.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(subscription.category.color.opacity(0.15))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(RoundedRectangle(cornerRadius: 20).fill(Theme.surface))
    }

    private var priceBreakdown: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Cost Breakdown")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }

            VStack(spacing: 1) {
                priceRow("Billing", value: "\(subscription.formattedPrice) \(subscription.billingCycle.rawValue)")
                priceRow("Monthly", value: subscription.formattedMonthlyPrice)
                priceRow("Yearly", value: "\(subscription.currency.symbol)\(NSDecimalNumber(decimal: subscription.yearlyPrice).doubleValue.formatted(.number.precision(.fractionLength(2))))", highlight: true)
                priceRow("Daily", value: "\(subscription.currency.symbol)\(NSDecimalNumber(decimal: subscription.dailyPrice).doubleValue.formatted(.number.precision(.fractionLength(2))))")
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func priceRow(_ label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .monospaced, weight: highlight ? .bold : .regular))
                .foregroundStyle(highlight ? Theme.electricCyan : Theme.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Theme.surface)
    }

    private var renewalInfo: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Renewal")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next renewal")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                    Text(subscription.nextRenewalDate.formatted(.dateTime.day().month().year()))
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("In")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                    Text("\(subscription.daysUntilRenewal) days")
                        .font(.system(.body, design: .monospaced, weight: .bold))
                        .foregroundStyle(subscription.isRenewingSoon ? Theme.coral : Theme.electricCyan)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(subscription.isRenewingSoon ? Theme.coral.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text(subscription.notes)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface))
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 10) {
            // Edit button
            Button {
                haptics.lightTap()
                showEditSheet = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Subscription")
                }
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(Theme.electricCyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.electricCyan, lineWidth: 1.5)
                )
            }

            if subscription.isActive {
                Button {
                    haptics.cancelSmash()
                    subscription.cancel()
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Cancel Subscription")
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.dangerGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            } else {
                Button {
                    haptics.success()
                    subscription.reactivate()
                } label: {
                    HStack {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                        Text("Reactivate")
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.cyanGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            Text("Started \(subscription.startDate.formatted(.dateTime.day().month().year()))")
                .font(.caption)
                .foregroundStyle(Theme.textMuted)
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionDetailView(subscription: Subscription(
            name: "Netflix",
            icon: "play.tv",
            price: 15.49,
            category: .streaming,
            nextRenewalDate: Calendar.current.date(byAdding: .day, value: 5, to: .now)!,
            colorHex: "E50914",
            notes: "Family plan, shared with roommates"
        ))
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}
