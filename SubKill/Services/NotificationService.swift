import UserNotifications

@Observable
final class NotificationService {
    var isAuthorized = false

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                isAuthorized = granted
            }
        } catch {
            print("Notification authorization error: \(error)")
        }
    }

    func scheduleRenewalReminder(for subscription: Subscription) {
        guard isAuthorized, subscription.isActive else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(subscription.name) renews soon"
        content.body = "\(subscription.formattedPrice)\(subscription.billingCycle.displayShort) renews in \(subscription.reminderDaysBefore) day\(subscription.reminderDaysBefore == 1 ? "" : "s"). Still worth it?"
        content.sound = .default
        content.badge = 1

        guard let triggerDate = Calendar.current.date(
            byAdding: .day,
            value: -subscription.reminderDaysBefore,
            to: subscription.nextRenewalDate
        ) else { return }

        // Don't schedule if trigger date is in the past
        guard triggerDate > .now else { return }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: triggerDate
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "renewal-\(subscription.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for subscription: Subscription) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: ["renewal-\(subscription.id.uuidString)"]
            )
    }

    func rescheduleAll(_ subscriptions: [Subscription]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for sub in subscriptions where sub.isActive {
            scheduleRenewalReminder(for: sub)
        }
    }
}
