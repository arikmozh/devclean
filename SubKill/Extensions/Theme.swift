import SwiftUI

enum Theme {
    // Primary Colors
    static let deepNavy = Color(hex: "0A1628")
    static let surface = Color(hex: "1A2332")
    static let surfaceLight = Color(hex: "243042")
    static let electricCyan = Color(hex: "00D4FF")
    static let coral = Color(hex: "FF6B6B")
    static let emerald = Color(hex: "00E676")

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "8899AA")
    static let textMuted = Color(hex: "556677")

    // Gradients
    static let mainGradient = LinearGradient(
        colors: [deepNavy, Color(hex: "0F1E30")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cyanGradient = LinearGradient(
        colors: [electricCyan, Color(hex: "0099CC")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let dangerGradient = LinearGradient(
        colors: [coral, Color(hex: "FF4444")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [surface, surfaceLight.opacity(0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Shadows
    static let glowCyan = Color(hex: "00D4FF").opacity(0.3)
    static let glowCoral = Color(hex: "FF6B6B").opacity(0.3)
}
