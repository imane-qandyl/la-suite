import Foundation
import os

final class ReminderStateStore {
    static let shared = ReminderStateStore()

    static let appGroupID = "group.com.lasuite.app"
    static let reminderKey = "reminderOn"
    static let reminderTextKey = "reminderText"
    static let reminderDateKey = "reminderDateISO8601"

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.lasuite.app",
        category: "ReminderStateStore"
    )

    private let defaults: UserDefaults
    private let storageSuite: String

    private init() {
        let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupID
        )

        // Only use the App Group suite when the signed container exists.
        // UserDefaults(suiteName:) can return non-nil even without a container,
        // which triggers CFPrefs "Container: (null)" errors and silent read failures.
        if let containerURL,
           let groupDefaults = UserDefaults(suiteName: Self.appGroupID) {
            defaults = groupDefaults
            storageSuite = Self.appGroupID
            Self.logger.info(
                "App Group ready. suite=\(Self.appGroupID, privacy: .public) container=\(containerURL.path, privacy: .public)"
            )
        } else {
            defaults = .standard
            storageSuite = "standard"
            Self.logger.error(
                "App Group '\(Self.appGroupID)' unavailable (containerURL=\(containerURL?.path ?? "nil", privacy: .public)). Using standard UserDefaults — enable App Groups in Signing & Capabilities."
            )
        }
    }

    var isUsingAppGroup: Bool {
        storageSuite == Self.appGroupID
    }

    var isReminderOn: Bool {
        let value = defaults.bool(forKey: Self.reminderKey)
        Self.logger.info(
            "[READ] suite=\(self.storageSuite, privacy: .public) key=\(Self.reminderKey, privacy: .public) value=\(value) usingAppGroup=\(self.isUsingAppGroup)"
        )
        return value
    }

    var reminderText: String? {
        defaults.string(forKey: Self.reminderTextKey)
    }

    var reminderDate: Date? {
        guard let isoString = defaults.string(forKey: Self.reminderDateKey) else {
            return nil
        }
        return Self.iso8601Formatter.date(from: isoString)
            ?? ISO8601DateFormatter().date(from: isoString)
    }

    func setReminderOn(_ on: Bool, caller: String = #function) {
        Self.logger.info(
            "[WRITE] caller=\(caller, privacy: .public) suite=\(self.storageSuite, privacy: .public) key=\(Self.reminderKey, privacy: .public) value=\(on) usingAppGroup=\(self.isUsingAppGroup)"
        )
        defaults.set(on, forKey: Self.reminderKey)

        if !on {
            defaults.removeObject(forKey: Self.reminderTextKey)
            defaults.removeObject(forKey: Self.reminderDateKey)
            Self.logger.info("[WRITE] cleared reminder text and date because reminder is OFF")
        }
    }

    func setReminder(content: String, date: Date, caller: String = #function) {
        let isoString = Self.iso8601Formatter.string(from: date)
        Self.logger.info(
            "[WRITE] caller=\(caller, privacy: .public) suite=\(self.storageSuite, privacy: .public) text=\(content, privacy: .public) date=\(isoString, privacy: .public)"
        )
        defaults.set(content, forKey: Self.reminderTextKey)
        defaults.set(isoString, forKey: Self.reminderDateKey)
    }
}
