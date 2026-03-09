import SwiftUI
import SwiftData

struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var price = ""
    @State private var selectedCurrency: AppCurrency = .usd
    @State private var billingCycle: BillingCycle = .monthly
    @State private var category: SubCategory = .other
    @State private var nextRenewal = Date()
    @State private var reminderDays = 2
    @State private var notes = ""
    @State private var selectedIcon = "creditcard"
    @State private var colorHex = "00D4FF"
    @State private var searchQuery = ""
    @State private var showServicePicker = true
    @State private var haptics = HapticService()

    private var filteredServices: [KnownService] {
        KnownService.search(searchQuery)
    }

    private var isValid: Bool {
        !name.isEmpty && !price.isEmpty && (Decimal(string: price) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.deepNavy.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Quick Pick (Known Services)
                        if showServicePicker {
                            quickPickSection
                        }

                        // Manual Entry
                        manualEntrySection

                        // Billing
                        billingSection

                        // Reminder
                        reminderSection

                        // Notes
                        notesSection

                        Spacer(minLength: 80)
                    }
                    .padding()
                }

                // Save Button
                VStack {
                    Spacer()
                    saveButton
                }
            }
            .navigationTitle("Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        haptics.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Quick Pick

    private var quickPickSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Services")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.textMuted)
                TextField("Search services...", text: $searchQuery)
                    .foregroundStyle(Theme.textPrimary)
                    .autocorrectionDisabled()
            }
            .padding(12)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Grid of services
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(filteredServices.prefix(16)) { service in
                    Button {
                        selectService(service)
                        haptics.mediumTap()
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(service.color.opacity(0.15))
                                    .frame(width: 48, height: 48)

                                Image(systemName: service.icon)
                                    .font(.title3)
                                    .foregroundStyle(service.color)
                            }

                            Text(service.name)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            }

            // Toggle manual entry
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showServicePicker.toggle()
                }
            } label: {
                HStack {
                    Text(showServicePicker ? "Enter manually" : "Pick from list")
                        .font(.system(.caption, design: .rounded))
                    Image(systemName: showServicePicker ? "keyboard" : "list.bullet")
                        .font(.caption)
                }
                .foregroundStyle(Theme.electricCyan)
            }
        }
    }

    // MARK: - Manual Entry

    private var manualEntrySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            // Name
            FormField(icon: "tag", placeholder: "Service name", text: $name)

            // Price + Currency
            HStack(spacing: 10) {
                FormField(icon: "banknote", placeholder: "Price", text: $price)
                    .keyboardType(.decimalPad)

                Picker("", selection: $selectedCurrency) {
                    ForEach(AppCurrency.allCases) { currency in
                        Text(currency.symbol).tag(currency)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.electricCyan)
                .padding(12)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Category
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SubCategory.allCases) { cat in
                        Button {
                            category = cat
                            haptics.selectionChanged()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: cat.icon)
                                    .font(.caption)
                                Text(cat.rawValue)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                            }
                            .foregroundStyle(category == cat ? .white : Theme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                category == cat
                                    ? AnyShapeStyle(cat.color.opacity(0.8))
                                    : AnyShapeStyle(Theme.surface)
                            )
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    // MARK: - Billing

    private var billingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Billing")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            // Cycle picker
            HStack(spacing: 8) {
                ForEach(BillingCycle.allCases) { cycle in
                    Button {
                        billingCycle = cycle
                        haptics.selectionChanged()
                    } label: {
                        Text(cycle.rawValue)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(billingCycle == cycle ? .white : Theme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                billingCycle == cycle
                                    ? AnyShapeStyle(Theme.cyanGradient)
                                    : AnyShapeStyle(Theme.surface)
                            )
                            .clipShape(Capsule())
                    }
                }
            }

            // Next renewal
            DatePicker(
                "Next Renewal",
                selection: $nextRenewal,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .tint(Theme.electricCyan)
            .foregroundStyle(Theme.textPrimary)
            .padding(12)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Reminder

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminder")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 8) {
                ForEach([1, 2, 3, 7], id: \.self) { days in
                    Button {
                        reminderDays = days
                        haptics.selectionChanged()
                    } label: {
                        Text("\(days)d before")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(reminderDays == days ? .white : Theme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                reminderDays == days
                                    ? AnyShapeStyle(Theme.cyanGradient)
                                    : AnyShapeStyle(Theme.surface)
                            )
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            TextField("Optional notes...", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .foregroundStyle(Theme.textPrimary)
                .padding(12)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Text("Add Subscription")
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isValid ? Theme.cyanGradient : LinearGradient(colors: [Theme.surfaceLight, Theme.surfaceLight], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: isValid ? Theme.glowCyan : .clear, radius: 12)
        }
        .disabled(!isValid)
        .padding(.horizontal)
        .padding(.bottom, 30)
        .background(
            LinearGradient(
                colors: [Theme.deepNavy.opacity(0), Theme.deepNavy],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            .allowsHitTesting(false)
        )
    }

    // MARK: - Actions

    private func selectService(_ service: KnownService) {
        name = service.name
        selectedIcon = service.icon
        colorHex = service.colorHex
        category = service.category
        price = "\(service.defaultPrice)"
        billingCycle = service.defaultCycle
        showServicePicker = false
    }

    private func save() {
        guard isValid, let priceDecimal = Decimal(string: price) else { return }

        let subscription = Subscription(
            name: name,
            icon: selectedIcon,
            price: priceDecimal,
            currency: selectedCurrency,
            billingCycle: billingCycle,
            category: category,
            startDate: .now,
            nextRenewalDate: nextRenewal,
            reminderDaysBefore: reminderDays,
            colorHex: colorHex,
            notes: notes
        )

        modelContext.insert(subscription)
        haptics.success()

        dismiss()
    }
}

// MARK: - Form Field

struct FormField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Theme.textMuted)
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .foregroundStyle(Theme.textPrimary)
                .autocorrectionDisabled()
        }
        .padding(12)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AddSubscriptionView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
