import SwiftUI
import SwiftData

@main
struct SubKillApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Subscription.self)
    }
}

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var notifications = NotificationService()

    var body: some View {
        if hasCompletedOnboarding {
            ContentView()
                .task {
                    await notifications.requestAuthorization()
                }
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var haptics = HapticService()

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "drop.fill")
                    Text("SubKill")
                }
                .tag(0)

            NavigationStack {
                StatisticsView()
            }
            .tabItem {
                Image(systemName: "chart.pie.fill")
                Text("Stats")
            }
            .tag(1)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
            .tag(2)
        }
        .tint(Theme.electricCyan)
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) { _, _ in
            haptics.selectionChanged()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
