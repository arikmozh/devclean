import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subscription.nextRenewalDate) private var allSubscriptions: [Subscription]

    @State private var viewModel = DashboardViewModel()
    @State private var haptics = HapticService()
    @State private var sounds = SoundService()
    @State private var showCancelAnimation = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Theme.deepNavy.ignoresSafeArea()

                if allSubscriptions.isEmpty {
                    EmptyStateView {
                        haptics.mediumTap()
                        viewModel.showingAddSheet = true
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Tank Animation
                            DrainTankView(
                                drainRate: viewModel.drainRate,
                                totalMonthly: viewModel.formatCurrency(viewModel.totalMonthly, currency: viewModel.primaryCurrency)
                            )
                            .padding(.top, 8)

                            // Quick Stats
                            QuickStatsBar(
                                daily: viewModel.formatCurrency(viewModel.totalDaily, currency: viewModel.primaryCurrency),
                                monthly: viewModel.formatCurrency(viewModel.totalMonthly, currency: viewModel.primaryCurrency),
                                yearly: viewModel.formatCurrency(viewModel.totalYearly, currency: viewModel.primaryCurrency),
                                saved: viewModel.totalSaved > 0
                                    ? viewModel.formatCurrency(viewModel.totalSaved, currency: viewModel.primaryCurrency)
                                    : ""
                            )
                            .padding(.horizontal)

                            // Smart Insights
                            let insights = InsightGenerator.generate(from: allSubscriptions)
                            if !insights.isEmpty {
                                InsightsCardView(insights: insights)
                            }

                            // Search Bar
                            if viewModel.activeSubscriptions.count >= 4 {
                                searchBar
                            }

                            // Upcoming Renewals
                            if !viewModel.upcomingRenewals.isEmpty {
                                upcomingSection
                            }

                            // All Subscriptions
                            subscriptionsList

                            // Cancelled
                            if !viewModel.cancelledSubscriptions.isEmpty {
                                cancelledSection
                            }

                            Spacer(minLength: 100)
                        }
                    }
                }

                // Cancel Animation Overlay
                if showCancelAnimation {
                    CancelAnimationView(
                        savedAmount: viewModel.formatCurrency(viewModel.lastSavedAmount, currency: viewModel.primaryCurrency)
                    ) {
                        withAnimation(.spring(response: 0.4)) {
                            showCancelAnimation = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .navigationTitle("SubKill")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: StatisticsView()) {
                        Image(systemName: "chart.pie")
                            .foregroundStyle(Theme.electricCyan)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        haptics.mediumTap()
                        viewModel.showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.electricCyan)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                AddSubscriptionView()
            }
            .confirmationDialog(
                "Cancel \(viewModel.subscriptionToCancel?.name ?? "")?",
                isPresented: $viewModel.showingCancelConfirm,
                titleVisibility: .visible
            ) {
                Button("Cancel Subscription", role: .destructive) {
                    viewModel.performCancel()
                    haptics.cancelSmash()
                    sounds.playSmash()
                    withAnimation(.spring(response: 0.3)) {
                        showCancelAnimation = true
                    }
                }
            } message: {
                if let sub = viewModel.subscriptionToCancel {
                    Text("You'll save \(sub.formattedPrice)\(sub.billingCycle.displayShort). This doesn't cancel the actual subscription with the provider.")
                }
            }
            .onChange(of: allSubscriptions) { _, newValue in
                viewModel.subscriptions = newValue
            }
            .onAppear {
                viewModel.subscriptions = allSubscriptions
                syncWidgetData()
            }
            .onChange(of: allSubscriptions) { _, newValue in
                syncWidgetData()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.textMuted)

            TextField("Search subscriptions", text: $viewModel.searchText)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .tint(Theme.electricCyan)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textMuted)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
        )
        .padding(.horizontal)
    }

    // MARK: - Sections

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Theme.coral)
                Text("Renewing Soon")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal)

            ForEach(viewModel.upcomingRenewals) { sub in
                SubscriptionRowView(subscription: sub) {
                    viewModel.confirmCancel(sub)
                }
                .padding(.horizontal)
            }
        }
    }

    private var subscriptionsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Active")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                Menu {
                    ForEach(DashboardViewModel.SortOption.allCases, id: \.self) { option in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.sortOption = option
                            }
                        } label: {
                            if viewModel.sortOption == option {
                                Label(option.rawValue, systemImage: "checkmark")
                            } else {
                                Text(option.rawValue)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.caption)
                        .foregroundStyle(Theme.textMuted)
                }

                Text("\(viewModel.activeSubscriptions.count)")
                    .font(.system(.subheadline, design: .monospaced, weight: .bold))
                    .foregroundStyle(Theme.electricCyan)
            }
            .padding(.horizontal)

            if viewModel.filteredSubscriptions.isEmpty && !viewModel.searchText.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundStyle(Theme.textMuted)
                        Text("No results for \"\(viewModel.searchText)\"")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            }

            ForEach(viewModel.filteredSubscriptions) { sub in
                NavigationLink(destination: SubscriptionDetailView(subscription: sub)) {
                    SubscriptionRowView(subscription: sub) {
                        viewModel.confirmCancel(sub)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
        }
    }

    private var cancelledSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.emerald)
                Text("Killed")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(viewModel.cancelledSubscriptions.count)")
                    .font(.system(.subheadline, design: .monospaced, weight: .bold))
                    .foregroundStyle(Theme.emerald)
            }
            .padding(.horizontal)

            ForEach(viewModel.cancelledSubscriptions) { sub in
                HStack {
                    SubscriptionRowView(subscription: sub) {}
                        .opacity(0.5)
                }
                .padding(.horizontal)
            }
        }
    }

    private func syncWidgetData() {
        let active = allSubscriptions.filter { $0.isActive }
        let sorted = active.sorted { $0.monthlyPrice > $1.monthlyPrice }
        let currency = active.first?.currency ?? .usd

        let widgetData = WidgetData(
            totalMonthly: NSDecimalNumber(decimal: viewModel.totalMonthly).doubleValue,
            totalDaily: NSDecimalNumber(decimal: viewModel.totalDaily).doubleValue,
            currencySymbol: currency.symbol,
            activeCount: active.count,
            topSubscriptions: sorted.prefix(3).map {
                WidgetSubscription(
                    id: $0.id.uuidString,
                    name: $0.name,
                    icon: $0.icon,
                    price: NSDecimalNumber(decimal: $0.monthlyPrice).doubleValue,
                    colorHex: $0.colorHex,
                    daysUntilRenewal: $0.daysUntilRenewal
                )
            },
            nextRenewal: active.sorted(by: { $0.nextRenewalDate < $1.nextRenewalDate }).first.map {
                WidgetSubscription(
                    id: $0.id.uuidString,
                    name: $0.name,
                    icon: $0.icon,
                    price: NSDecimalNumber(decimal: $0.price).doubleValue,
                    colorHex: $0.colorHex,
                    daysUntilRenewal: $0.daysUntilRenewal
                )
            },
            lastUpdated: .now
        )
        SharedDataManager.save(widgetData)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
