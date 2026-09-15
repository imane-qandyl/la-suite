import AppIntents
import os

private let intentLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.lasuite.app",
    category: "ActivateReminderIntent"
)

struct ActivateReminderIntent: AppIntent {
    static var title: LocalizedStringResource = "Activate Reminder"
    static var description = IntentDescription("Turns the La Suite reminder toggle on.")

    // Siri runs App Shortcuts in a separate process when false; App Group is only
    // available in the main app process. Shortcuts often launches the app, which is
    // why it worked there but not via Siri.
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        print("[INTENT] Activate Reminder perform() START")
        intentLogger.info("[INTENT] Activate Reminder perform() START")

        let suiteName = ReminderStateStore.appGroupID
        let key = ReminderStateStore.reminderKey
        let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: suiteName
        )

        intentLogger.info(
            "Intent context containerURL=\(containerURL?.path ?? "nil", privacy: .public) usingAppGroup=\(ReminderStateStore.shared.isUsingAppGroup)"
        )

        print("[WRITE] suite=\(suiteName) key=\(key) value=true")
        intentLogger.info("[WRITE] suite=\(suiteName, privacy: .public) key=\(key, privacy: .public) value=true")

        guard let defaults = UserDefaults(suiteName: suiteName) else {
            print("[WRITE] FAILED - UserDefaults(suiteName:) returned nil")
            intentLogger.error("[WRITE] FAILED - UserDefaults(suiteName:) returned nil")
            throw IntentError.appGroupUnavailable
        }

        defaults.set(true, forKey: key)

        let readBack = defaults.bool(forKey: key)
        print("[WRITE] reminderOn after write = \(readBack)")
        intentLogger.info("[WRITE] reminderOn after write = \(readBack)")

        intentLogger.info(
            "ActivateReminderIntent completed. readBack=\(readBack) containerURL=\(containerURL?.path ?? "nil", privacy: .public)"
        )

        return .result(dialog: IntentDialog("Reminder activated in La Suite."))
    }
}

private enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case appGroupUnavailable

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .appGroupUnavailable:
            return "Could not access shared La Suite state."
        }
    }
}
