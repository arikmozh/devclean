import SwiftUI

struct QuickStatsBar: View {
    let daily: String
    let monthly: String
    let yearly: String
    let saved: String

    var body: some View {
        HStack(spacing: 0) {
            StatPill(label: "Daily", value: daily, color: Theme.textSecondary)
            StatDivider()
            StatPill(label: "Monthly", value: monthly, color: Theme.electricCyan)
            StatDivider()
            StatPill(label: "Yearly", value: yearly, color: Theme.coral)
            if !saved.isEmpty {
                StatDivider()
                StatPill(label: "Saved", value: saved, color: Theme.emerald)
            }
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.surface)
        )
    }
}

private struct StatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textMuted)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StatDivider: View {
    var body: some View {
        Rectangle()
            .fill(Theme.surfaceLight)
            .frame(width: 1, height: 30)
    }
}

#Preview {
    ZStack {
        Theme.deepNavy.ignoresSafeArea()
        QuickStatsBar(daily: "$4.25", monthly: "$127.50", yearly: "$1,530", saved: "$360")
            .padding()
    }
}
