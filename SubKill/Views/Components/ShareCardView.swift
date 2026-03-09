import SwiftUI

struct ShareCardView: View {
    let totalMonthly: String
    let totalYearly: String
    let totalSaved: String
    let activeCount: Int
    let killedCount: Int

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(Theme.electricCyan)
                Text("SubKill")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }

            // Stats
            VStack(spacing: 12) {
                HStack {
                    shareStatBox(value: totalMonthly, label: "Monthly", color: Theme.electricCyan)
                    shareStatBox(value: totalYearly, label: "Yearly", color: Theme.coral)
                }
                HStack {
                    shareStatBox(value: "\(activeCount)", label: "Active", color: .purple)
                    shareStatBox(value: totalSaved, label: "Saved", color: Theme.emerald)
                }
            }

            // Killed count
            if killedCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.emerald)
                    Text("Killed \(killedCount) subscription\(killedCount == 1 ? "" : "s")")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(Theme.emerald)
                }
            }

            // Footer
            HStack {
                Spacer()
                Text("Track yours at SubKill app")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.deepNavy)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Theme.surfaceLight, lineWidth: 1)
        )
        .frame(width: 340)
    }

    private func shareStatBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .monospaced, weight: .bold))
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.surface)
        )
    }

    @MainActor
    func renderAsImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3
        return renderer.uiImage
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ShareCardView(
            totalMonthly: "$127.50",
            totalYearly: "$1,530",
            totalSaved: "$360",
            activeCount: 12,
            killedCount: 3
        )
    }
}
