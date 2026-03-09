import SwiftUI

struct DrainTankView: View {
    let drainRate: Double // 0.0 (empty) to 1.0 (full drain)
    let totalMonthly: String

    @State private var waveOffset: Double = 0
    @State private var dripY: CGFloat = -20
    @State private var dripOpacity: Double = 1
    @State private var showDrip: Bool = false

    private let tankHeight: CGFloat = 200
    private var waterLevel: CGFloat {
        tankHeight * CGFloat(1 - drainRate) // More drain = less water
    }

    var body: some View {
        VStack(spacing: 16) {
            // Total monthly display
            Text(totalMonthly)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(drainRate > 0.7 ? Theme.coral : Theme.electricCyan)
                .contentTransition(.numericText())
                .shadow(color: drainRate > 0.7 ? Theme.glowCoral : Theme.glowCyan, radius: 20)

            Text("per month")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            // Tank visualization
            ZStack {
                // Tank outline
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.surfaceLight, lineWidth: 2)
                    .frame(width: 120, height: tankHeight)

                // Water fill
                ZStack {
                    // Wave animation
                    WaveShape(offset: waveOffset, amplitude: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    drainRate > 0.7 ? Theme.coral.opacity(0.6) : Theme.electricCyan.opacity(0.6),
                                    drainRate > 0.7 ? Theme.coral.opacity(0.3) : Theme.electricCyan.opacity(0.3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    WaveShape(offset: waveOffset + 0.5, amplitude: 3)
                        .fill(
                            drainRate > 0.7
                                ? Theme.coral.opacity(0.3)
                                : Theme.electricCyan.opacity(0.2)
                        )
                }
                .frame(width: 116, height: max(waterLevel, 10))
                .frame(height: tankHeight, alignment: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // Drip
                if showDrip && drainRate > 0 {
                    Circle()
                        .fill(drainRate > 0.7 ? Theme.coral : Theme.electricCyan)
                        .frame(width: 8, height: 8)
                        .offset(y: tankHeight / 2 + dripY)
                        .opacity(dripOpacity)
                        .shadow(color: drainRate > 0.7 ? Theme.glowCoral : Theme.glowCyan, radius: 6)
                }
            }
            .frame(height: tankHeight + 40)

            // Drain rate label
            HStack(spacing: 4) {
                Image(systemName: drainRate > 0.7 ? "exclamationmark.triangle.fill" : "drop.fill")
                    .foregroundStyle(drainRate > 0.7 ? Theme.coral : Theme.electricCyan)
                    .font(.caption)

                Text(drainLabel)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private var drainLabel: String {
        switch drainRate {
        case 0: return "No active subscriptions"
        case 0.01..<0.3: return "Healthy spending"
        case 0.3..<0.7: return "Moderate drain"
        case 0.7...: return "Heavy drain!"
        default: return ""
        }
    }

    private func startAnimations() {
        // Wave animation
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            waveOffset = 1
        }

        // Drip animation
        startDripCycle()
    }

    private func startDripCycle() {
        guard drainRate > 0 else { return }

        showDrip = true
        dripY = -20
        dripOpacity = 1

        let speed = 2.0 - drainRate // Faster drip when more subscriptions

        withAnimation(.easeIn(duration: speed)) {
            dripY = 30
            dripOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + speed + 0.3) {
            startDripCycle()
        }
    }
}

// MARK: - Wave Shape

struct WaveShape: Shape {
    var offset: Double
    var amplitude: CGFloat

    var animatableData: Double {
        get { offset }
        set { offset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: 0))

        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX + offset) * 2 * .pi)
            let y = amplitude * CGFloat(sine)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    ZStack {
        Theme.deepNavy.ignoresSafeArea()
        DrainTankView(drainRate: 0.5, totalMonthly: "$127.50")
    }
}
