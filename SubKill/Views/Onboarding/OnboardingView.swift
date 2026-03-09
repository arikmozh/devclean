import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var haptics = HapticService()

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "drop.fill",
            iconColor: Color(hex: "00D4FF"),
            title: "Your money is dripping away",
            subtitle: "The average person wastes $133/month on forgotten subscriptions. SubKill shows you exactly where every dollar goes.",
            highlight: "$133/month"
        ),
        OnboardingPage(
            icon: "bell.badge.fill",
            iconColor: Color(hex: "FF6B6B"),
            title: "Never get surprised again",
            subtitle: "Get smart alerts before any subscription renews. Decide if it's still worth it — before you're charged.",
            highlight: "before you're charged"
        ),
        OnboardingPage(
            icon: "xmark.circle.fill",
            iconColor: Color(hex: "00E676"),
            title: "Kill what you don't need",
            subtitle: "Cancel subscriptions with a satisfying smash. Track how much money you've saved over time.",
            highlight: "how much money you've saved"
        ),
        OnboardingPage(
            icon: "heart.fill",
            iconColor: Color(hex: "00D4FF"),
            title: "No subscription. No ads. No tracking.",
            subtitle: "SubKill is a one-time purchase. We don't sell your data. We don't show ads. We just help you save money.",
            highlight: "one-time purchase"
        )
    ]

    var body: some View {
        ZStack {
            Theme.deepNavy.ignoresSafeArea()

            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4), value: currentPage)

                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Theme.electricCyan : Theme.surfaceLight)
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 30)

                // Button
                Button {
                    haptics.mediumTap()
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.cyanGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.glowCyan, radius: 12)
                }
                .padding(.horizontal, 30)

                if currentPage < pages.count - 1 {
                    Button {
                        hasCompletedOnboarding = true
                    } label: {
                        Text("Skip")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Theme.textMuted)
                    }
                    .padding(.top, 12)
                }

                Spacer().frame(height: 40)
            }
        }
        .onChange(of: currentPage) { _, _ in
            haptics.selectionChanged()
        }
    }

    private func onboardingPageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon with glow
            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.1))
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(page.iconColor.opacity(0.05))
                    .frame(width: 180, height: 180)

                Image(systemName: page.icon)
                    .font(.system(size: 56))
                    .foregroundStyle(page.iconColor)
                    .shadow(color: page.iconColor.opacity(0.5), radius: 20)
            }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 30)

            Spacer()
            Spacer()
        }
    }
}

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let highlight: String
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
