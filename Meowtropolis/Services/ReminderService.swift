import Foundation
import UserNotifications

/// Simple local-notification helper for booking reminders.
final class ReminderService {
    static let preferenceKey = "enableReminders"

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    /// Requests local notification permission from the user.
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion?(granted)
        }
    }

    /// Returns a simple permission state for UI labels.
    func getPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    /// Schedules one reminder about one hour before the booking time.
    func scheduleBookingReminder(_ booking: Booking) {
        let isoFormatter = ISO8601DateFormatter()

        guard let bookingDate = isoFormatter.date(from: booking.date) else {
            return
        }

        // Default reminder time is one hour before booking.
        var reminderDate = bookingDate.addingTimeInterval(-3600)

        // If that reminder time is already in the past, use one minute from now.
        if reminderDate <= Date() {
            reminderDate = Date().addingTimeInterval(60)
        }

        let content = UNMutableNotificationContent()
        content.title = "Booking Reminder"
        content.body = "Your grooming appointment is coming up."
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: reminderIdentifier(for: booking.id),
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    /// Cancels a scheduled reminder for a booking.
    func cancelReminder(bookingId: String) {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier(for: bookingId)])
    }

    private func reminderIdentifier(for bookingId: String) -> String {
        "booking-reminder-\(bookingId)"
    }
}
