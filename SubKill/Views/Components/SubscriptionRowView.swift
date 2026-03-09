import SwiftUI
import SwiftData

struct SubscriptionRowView: View {
    let subscription: Subscription
    let onCancel: () -> Void

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(subscription.color.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: subscription.icon)
                    .font(.title3)
                    .foregroundStyle(subscription.color)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                HStack(spacing: 6) {
                    Text(subscription.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(subscription.category.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(subscription.category.color.opacity(0.15))
                        .clipShape(Capsule())

                    if subscription.isRenewingSoon {
                        Text("Renews in \(subscription.daysUntilRenewal)d")
                            .font(.caption2)
                            .foregroundStyle(Theme.coral)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.coral.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            // Price
            VStack(alignment: .trailing, spacing: 2) {
                Text(subscription.formattedPrice)
                    .font(.system(.body, design: .monospaced, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                Text(subscription.billingCycle.displayShort)
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.surface)
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    subscription.isRenewingSoon ? Theme.coral.opacity(0.3) : .clear,
                    lineWidth: 1
                )
        )
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .contextMenu {
            Button {
                onCancel()
            } label: {
                Label("Cancel Subscription", systemImage: "xmark.circle")
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.deepNavy.ignoresSafeArea()
        VStack(spacing: 12) {
            SubscriptionRowView(
                subscription: Subscription(
                    name: "Netflix",
                    icon: "play.tv",
                    price: 15.49,
                    category: .streaming,
                    colorHex: "E50914"
                ),
                onCancel: {}
            )
        }
        .padding()
    }
}
