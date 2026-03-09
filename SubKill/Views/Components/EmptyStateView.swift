import SwiftUI

struct EmptyStateView: View {
    let onAddTapped: () -> Void

    @State private var dropOffset: CGFloat = -60
    @State private var dropOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Animated icon
            ZStack {
                // Pulse ring
                Circle()
                    .stroke(Theme.electricCyan.opacity(0.2), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseScale)

                // Tank icon
                Image(systemName: "drop.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.textSecondary)

                // Animated drop
                Image(systemName: "drop.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.electricCyan)
                    .offset(y: dropOffset)
                    .opacity(dropOpacity)
            }
            .frame(height: 140)

            VStack(spacing: 8) {
                Text("No Subscriptions Yet")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                Text("Add your first subscription to start\ntracking where your money goes")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                onAddTapped()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Subscription")
                }
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Theme.cyanGradient)
                .clipShape(Capsule())
                .shadow(color: Theme.glowCyan, radius: 12)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
            startDropAnimation()
        }
    }

    private func startDropAnimation() {
        dropOffset = -60
        dropOpacity = 0

        withAnimation(.easeIn(duration: 0.3)) {
            dropOpacity = 0.6
        }

        withAnimation(.easeIn(duration: 1.2)) {
            dropOffset = 20
        }

        withAnimation(.easeIn(duration: 0.3).delay(1.0)) {
            dropOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            startDropAnimation()
        }
    }
}

#Preview {
    ZStack {
        Theme.deepNavy.ignoresSafeArea()
        EmptyStateView(onAddTapped: {})
    }
}
