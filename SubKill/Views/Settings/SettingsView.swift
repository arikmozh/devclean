import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @AppStorage("defaultCurrency") private var defaultCurrency = AppCurrency.usd.rawValue
    @AppStorage("defaultReminderDays") private var defaultReminderDays = 2
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @Query private var subscriptions: [Subscription]
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    @State private var haptics = HapticService()
    @State private var showExportSheet = false
    @State private var exportURL: URL?

    private var active: [Subscription] { subscriptions.filter { $0.isActive } }
    private var cancelled: [Subscription] { subscriptions.filter { !$0.isActive } }
    private var totalMonthly: Decimal { active.reduce(0) { $0 + $1.monthlyPrice } }
    private var totalSaved: Decimal {
        cancelled.reduce(0) { t, s in
            guard let d = s.cancelledDate else { return t }
            let m = Calendar.current.dateComponents([.month], from: d, to: .now).month ?? 0
            return t + (s.monthlyPrice * Decimal(max(m, 1)))
        }
    }

    private func fmt(_ d: Decimal) -> String {
        let sym = active.first?.currency.symbol ?? "$"
        return "\(sym)\(NSDecimalNumber(decimal: d).doubleValue.formatted(.number.precision(.fractionLength(2))))"
    }

    var body: some View {
        ZStack {
            Theme.deepNavy.ignoresSafeArea()

            List {
                Section("Defaults") {
                    Picker("Currency", selection: $defaultCurrency) {
                        ForEach(AppCurrency.allCases) { currency in
                            Text("\(currency.symbol) \(currency.rawValue)").tag(currency.rawValue)
                        }
                    }
                    .listRowBackground(Theme.surface)

                    Picker("Remind before", selection: $defaultReminderDays) {
                        Text("1 day").tag(1)
                        Text("2 days").tag(2)
                        Text("3 days").tag(3)
                        Text("7 days").tag(7)
                    }
                    .listRowBackground(Theme.surface)
                }

                Section("Feedback") {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                        .listRowBackground(Theme.surface)
                    Toggle("Haptic Feedback", isOn: $hapticEnabled)
                        .listRowBackground(Theme.surface)
                }

                Section("Share & Export") {
                    Button {
                        haptics.mediumTap()
                        let card = ShareCardView(
                            totalMonthly: fmt(totalMonthly),
                            totalYearly: fmt(totalMonthly * 12),
                            totalSaved: fmt(totalSaved),
                            activeCount: active.count,
                            killedCount: cancelled.count
                        )
                        shareImage = card.renderAsImage()
                        showShareSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(Theme.electricCyan)
                            Text("Share My Stats")
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .listRowBackground(Theme.surface)

                    Button {
                        haptics.mediumTap()
                        let csv = ExportService.generateCSV(from: subscriptions)
                        if let url = ExportService.saveCSVToTempFile(csv) {
                            exportURL = url
                            showExportSheet = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "tablecells")
                                .foregroundStyle(Theme.emerald)
                            Text("Export to CSV")
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .listRowBackground(Theme.surface)

                    Button {
                        haptics.lightTap()
                        requestReview()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("Rate SubKill")
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .listRowBackground(Theme.surface)
                }

                Section("Support") {
                    NavigationLink(destination: TipJarView()) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(Theme.coral)
                            Text("Tip Jar")
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .listRowBackground(Theme.surface)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundStyle(Theme.textSecondary)
                    }
                    .listRowBackground(Theme.surface)

                    HStack {
                        Text("Subscriptions tracked")
                        Spacer()
                        Text("\(subscriptions.count)").foregroundStyle(Theme.electricCyan)
                    }
                    .listRowBackground(Theme.surface)

                    HStack {
                        Text("Money saved")
                        Spacer()
                        Text(fmt(totalSaved)).foregroundStyle(Theme.emerald)
                    }
                    .listRowBackground(Theme.surface)
                }

                Section {
                    VStack(spacing: 8) {
                        Text("SubKill")
                            .font(.system(.headline, design: .rounded))
                        Text("The subscription tracker that\ndoesn't charge a subscription.")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .tint(Theme.electricCyan)
            .foregroundStyle(Theme.textPrimary)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image, "I'm tracking my subscriptions with SubKill!" as Any])
            }
        }
        .sheet(isPresented: $showExportSheet) {
            if let url = exportURL {
                ShareSheet(items: [url as Any])
            }
        }
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        AppStore.requestReview(in: scene)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}
