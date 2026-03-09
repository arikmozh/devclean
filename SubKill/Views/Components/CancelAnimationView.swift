import SwiftUI

struct CancelAnimationView: View {
    let savedAmount: String
    let onDismiss: () -> Void

    @State private var showSmash = false
    @State private var particles: [Particle] = []
    @State private var showSavedText = false
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture { onDismiss() }

                VStack(spacing: 30) {
                    Spacer()

                    ZStack {
                        ForEach(particles) { particle in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(particle.color)
                                .frame(width: particle.size, height: particle.size)
                                .offset(x: particle.x, y: particle.y)
                                .rotationEffect(.degrees(particle.rotation))
                                .opacity(particle.opacity)
                        }

                        if showSmash {
                            Circle()
                                .fill(Theme.coral.opacity(0.6))
                                .frame(width: 100, height: 100)
                                .scaleEffect(showSmash ? 3 : 0)
                                .opacity(showSmash ? 0 : 1)
                        }
                    }
                    .frame(height: 200)

                    if showSavedText {
                        VStack(spacing: 8) {
                            Text("KILLED IT!")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(Theme.emerald)

                            Text("You'll save")
                                .font(.system(.title3, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)

                            Text(savedAmount)
                                .font(.system(size: 52, weight: .bold, design: .monospaced))
                                .foregroundStyle(Theme.emerald)
                                .shadow(color: Theme.emerald.opacity(0.5), radius: 20)

                            Text("per year")
                                .font(.system(.title3, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }

                    Spacer()

                    ForEach(confettiPieces) { piece in
                        Circle()
                            .fill(piece.color)
                            .frame(width: piece.size, height: piece.size)
                            .position(x: piece.x, y: piece.y)
                            .opacity(piece.opacity)
                    }

                    if showSavedText {
                        Button {
                            onDismiss()
                        } label: {
                            Text("Nice!")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Theme.cyanGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .onAppear {
                triggerAnimation(screenSize: geo.size)
            }
        }
    }

    private func triggerAnimation(screenSize: CGSize) {
        withAnimation(.easeOut(duration: 0.2)) {
            showSmash = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generateParticles()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                scatterParticles()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.5)) {
                fadeParticles()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showSavedText = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            generateConfetti(screenSize: screenSize)
        }
    }

    private func generateParticles() {
        let colors: [Color] = [Theme.coral, .orange, .yellow, .red, Theme.electricCyan]
        particles = (0..<20).map { _ in
            Particle(x: 0, y: 0, size: CGFloat.random(in: 6...16), color: colors.randomElement()!, rotation: 0, opacity: 1)
        }
    }

    private func scatterParticles() {
        for i in particles.indices {
            particles[i].x = CGFloat.random(in: -150...150)
            particles[i].y = CGFloat.random(in: -120...120)
            particles[i].rotation = Double.random(in: -360...360)
        }
    }

    private func fadeParticles() {
        for i in particles.indices {
            particles[i].opacity = 0
            particles[i].y += 50
        }
    }

    private func generateConfetti(screenSize: CGSize) {
        let colors: [Color] = [Theme.emerald, Theme.electricCyan, .yellow, .orange, .pink, .purple]
        confettiPieces = (0..<30).map { _ in
            ConfettiPiece(x: CGFloat.random(in: 0...screenSize.width), y: -20, size: CGFloat.random(in: 4...10), color: colors.randomElement()!, opacity: 1)
        }
        withAnimation(.easeIn(duration: 2)) {
            for i in confettiPieces.indices {
                confettiPieces[i].y = screenSize.height + 50
                confettiPieces[i].x += CGFloat.random(in: -80...80)
                confettiPieces[i].opacity = 0
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var rotation: Double
    var opacity: Double
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}
