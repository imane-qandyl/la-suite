import EventKit
import Foundation
import os

enum ReminderServiceError: LocalizedError {
    case accessDenied
    case noDefaultCalendar
    case saveFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Reminders access was denied. Open La Suite once and allow Reminders access in Settings."
        case .noDefaultCalendar:
            return "No default Reminders list is available on this device."
        case .saveFailed(let underlying):
            return "Could not save the reminder: \(underlying.localizedDescription)"
        }
    }
}

final class ReminderService {
    static let shared = ReminderService()

    private let store = EKEventStore()
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.lasuite.app",
        category: "ReminderService"
    )

    private init() {}

    func createReminder(title: String, dueDate: Date) async throws {
        try await requestAccessIfNeeded()

        guard let calendar = store.defaultCalendarForNewReminders() else {
            logger.error("No default Reminders calendar available")
            throw ReminderServiceError.noDefaultCalendar
        }

        let reminder = EKReminder(eventStore: store)
        reminder.title = title
        reminder.calendar = calendar
        reminder.dueDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )
        reminder.addAlarm(EKAlarm(absoluteDate: dueDate))

        do {
            try store.save(reminder, commit: true)
            logger.info(
                "Created EventKit reminder title=\(title, privacy: .public) dueDate=\(dueDate.formatted(), privacy: .public) calendar=\(calendar.title, privacy: .public)"
            )
        } catch {
            logger.error("Failed to save EventKit reminder: \(error.localizedDescription, privacy: .public)")
            throw ReminderServiceError.saveFailed(underlying: error)
        }
    }

    private func requestAccessIfNeeded() async throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        logger.info("Reminders authorization status=\(String(describing: status))")

        if #available(iOS 17.0, *) {
            switch status {
            case .fullAccess:
                return
            case .writeOnly:
                // writeOnly is sufficient for creating reminders
                return
            case .authorized:
                return
            case .notDetermined:
                let granted = try await store.requestFullAccessToReminders()
                guard granted else { throw ReminderServiceError.accessDenied }
            case .denied, .restricted:
                throw ReminderServiceError.accessDenied
            @unknown default:
                throw ReminderServiceError.accessDenied
            }
            return
        }

        switch status {
        case .fullAccess:
            return
        case .writeOnly:
            // writeOnly is sufficient for creating reminders
            return
        case .authorized:
            return
        case .notDetermined:
            let granted = try await store.requestAccess(to: .reminder)
            guard granted else { throw ReminderServiceError.accessDenied }
        case .denied, .restricted:
            throw ReminderServiceError.accessDenied
        @unknown default:
            throw ReminderServiceError.accessDenied
        }
    }
}
