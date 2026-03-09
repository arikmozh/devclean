import SwiftUI
import SwiftData

struct EditSubscriptionView: View {
    @Bindable var subscription: Subscription
    @Environment(\.dismiss) private var dismiss
    @State private var haptics = HapticService()

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var selectedCurrency: AppCurrency = .usd
    @State private var billingCycle: BillingCycle = .monthly
    @State private var category: SubCategory = .other
    @State private var nextRenewal: Date = .now
    @State private var reminderDays: Int = 2
    @State private var notes: String = ""

    private var isValid: Bool {
        !name.isEmpty && !price.isEmpty && (Decimal(string: price) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.deepNavy.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)

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

                        // Billing Cycle
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Billing Cycle")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)

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
                        }

                        // Next Renewal
                        DatePicker("Next Renewal", selection: $nextRenewal, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .tint(Theme.electricCyan)
                            .foregroundStyle(Theme.textPrimary)
                            .padding(12)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Reminder
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Remind before renewal")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)

                            HStack(spacing: 8) {
                                ForEach([1, 2, 3, 7], id: \.self) { days in
                                    Button {
                                        reminderDays = days
                                        haptics.selectionChanged()
                                    } label: {
                                        Text("\(days)d")
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

                        // Notes
                        TextField("Notes...", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundStyle(Theme.textPrimary)
                            .padding(12)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Spacer(minLength: 80)
                    }
                    .padding()
                }

                // Save Button
                VStack {
                    Spacer()
                    Button {
                        save()
                    } label: {
                        Text("Save Changes")
                            .font(.system(.body, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isValid ? Theme.cyanGradient : LinearGradient(colors: [Theme.surfaceLight], startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: isValid ? Theme.glowCyan : .clear, radius: 12)
                    }
                    .disabled(!isValid)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
            }
            .onAppear {
                name = subscription.name
                price = "\(subscription.price)"
                selectedCurrency = subscription.currency
                billingCycle = subscription.billingCycle
                category = subscription.category
                nextRenewal = subscription.nextRenewalDate
                reminderDays = subscription.reminderDaysBefore
                notes = subscription.notes
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        guard isValid, let priceDecimal = Decimal(string: price) else { return }
        subscription.name = name
        subscription.price = priceDecimal
        subscription.currency = selectedCurrency
        subscription.billingCycle = billingCycle
        subscription.category = category
        subscription.nextRenewalDate = nextRenewal
        subscription.reminderDaysBefore = reminderDays
        subscription.notes = notes
        subscription.updatedAt = .now
        haptics.success()
        dismiss()
    }
}
