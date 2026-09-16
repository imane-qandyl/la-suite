import Foundation
import os

// MARK: - ReminderItem

/// A single reminder stored in the App Group.
struct ReminderItem: Codable {
    let id: String
    let text: String
    let date: String   // ISO8601
}

// MARK: - ReminderStateStore

final class ReminderStateStore {
    static let shared = ReminderStateStore()

    // MARK: App Group keys
    static let appGroupID       = "group.com.lasuite.app"
    static let reminderKey      = "reminderOn"          // Bool — kept for ActivateReminderIntent
    static let remindersKey     = "reminders"           // JSON [ReminderItem]

    // Legacy keys — no longer written, kept only so old reads don't crash
    static let reminderTextKey  = "reminderText"
    static let reminderDateKey  = "reminderDateISO8601"

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
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
                "App Group '\(Self.appGroupID)' unavailable. Using standard UserDefaults."
            )
        }
    }

    // MARK: - Public interface

    var isUsingAppGroup: Bool { storageSuite == Self.appGroupID }

    /// True when at least one reminder is stored.
    var isReminderOn: Bool {
        let value = defaults.bool(forKey: Self.reminderKey)
        Self.logger.info(
            "[READ] suite=\(self.storageSuite, privacy: .public) key=reminderOn value=\(value)"
        )
        return value
    }

    /// All currently stored reminders, newest-last.
    var reminders: [ReminderItem] {
        guard let data = defaults.data(forKey: Self.remindersKey) else {
            Self.logger.info("[DEBUG-READ] no data for key '\(Self.remindersKey, privacy: .public)' — returning []")
            return []
        }
        do {
            let items = try JSONDecoder().decode([ReminderItem].self, from: data)
            Self.logger.info("[DEBUG-READ] decoded \(items.count) reminders from suite=\(self.storageSuite, privacy: .public)")
            return items
        } catch {
            Self.logger.error("Failed to decode reminders: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    // MARK: - Write operations

    /// Appends a new reminder to the stored list and sets reminderOn = true.
    func appendReminder(content: String, date: Date, caller: String = #function) {
        let isoString = Self.iso8601Formatter.string(from: date)
        let item = ReminderItem(id: UUID().uuidString, text: content, date: isoString)

        var existing = reminders
        existing.append(item)

        do {
            let data = try JSONEncoder().encode(existing)
            defaults.set(data, forKey: Self.remindersKey)
            defaults.set(true, forKey: Self.reminderKey)
            // Force synchronise so the write is not lost if the process is killed
            defaults.synchronize()
            let jsonString = String(data: data, encoding: .utf8) ?? "nil"
            Self.logger.info(
                "[WRITE] appendReminder caller=\(caller, privacy: .public) id=\(item.id, privacy: .public) text=\(content, privacy: .public) date=\(isoString, privacy: .public) total=\(existing.count) json=\(jsonString, privacy: .public)"
            )
            print("[WRITE] appendReminder total=\(existing.count) json=\(jsonString)")
        } catch {
            Self.logger.error("Failed to encode reminders: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Turns the reminder toggle on/off.
    /// Passing false clears the entire reminder list (preserves existing OFF behaviour).
    func setReminderOn(_ on: Bool, caller: String = #function) {
        Self.logger.info(
            "[WRITE] setReminderOn caller=\(caller, privacy: .public) value=\(on)"
        )
        defaults.set(on, forKey: Self.reminderKey)

        if !on {
            defaults.removeObject(forKey: Self.remindersKey)
            // Also clear legacy singleton keys if still present
            defaults.removeObject(forKey: Self.reminderTextKey)
            defaults.removeObject(forKey: Self.reminderDateKey)
            Self.logger.info("[WRITE] cleared all reminders (reminderOn = false)")
        }
    }

    // MARK: - Legacy shim (used only by ActivateReminderIntent — no behaviour change)

    /// Kept so ActivateReminderIntent compiles without modification.
    /// ActivateReminderIntent only calls setReminderOn(true), which is unchanged.
    var reminderText: String? { reminders.last?.text }
    var reminderDate: Date? {
        guard let iso = reminders.last?.date else { return nil }
        return Self.iso8601Formatter.date(from: iso)
            ?? ISO8601DateFormatter().date(from: iso)
    }
}
