import SwiftUI
import StoreKit

struct TipJarView: View {
    @State private var haptics = HapticService()
    @State private var showThankYou = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.coral)
                    .shadow(color: Theme.glowCoral, radius: 12)

                Text("Love SubKill?")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                Text("SubKill is a one-time purchase with no ads.\nIf it's saving you money, consider leaving a tip!")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            // Tip buttons
            VStack(spacing: 10) {
                tipButton(emoji: "☕️", label: "Buy me a coffee", amount: "$1.99", productId: "com.klause.subkill.tip.small")
                tipButton(emoji: "🍕", label: "Buy me a pizza", amount: "$4.99", productId: "com.klause.subkill.tip.medium")
                tipButton(emoji: "🎉", label: "You're amazing!", amount: "$9.99", productId: "com.klause.subkill.tip.large")
            }
            .padding(.horizontal)

            Spacer()

            if showThankYou {
                VStack(spacing: 4) {
                    Text("Thank you!")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Theme.emerald)
                    Text("Your support means everything")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.deepNavy)
        .navigationTitle("Tip Jar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func tipButton(emoji: String, label: String, amount: String, productId: String) -> some View {
        Button {
            haptics.success()
            // StoreKit purchase will be implemented with actual product IDs
            withAnimation(.spring(response: 0.4)) {
                showThankYou = true
            }
        } label: {
            HStack {
                Text(emoji)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                }

                Spacer()

                Text(amount)
                    .font(.system(.body, design: .monospaced, weight: .bold))
                    .foregroundStyle(Theme.electricCyan)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.surface)
            )
        }
    }
}

#Preview {
    NavigationStack {
        TipJarView()
    }
}
