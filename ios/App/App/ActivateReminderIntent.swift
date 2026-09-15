import AppIntents
import os

private let intentLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.lasuite.app",
    category: "ActivateReminderIntent"
)

struct ActivateReminderIntent: AppIntent {
    static var title: LocalizedStringResource = "Activate Reminder"
    static var description = IntentDescription("Turns the La Suite reminder toggle on.")

    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        intentLogger.info(
            "Performing ActivateReminderIntent. appGroup=\(ReminderStateStore.appGroupID, privacy: .public) usingAppGroup=\(ReminderStateStore.shared.isUsingAppGroup)"
        )
        ReminderStateStore.shared.setReminderOn(true, caller: "ActivateReminderIntent.perform")
        intentLogger.info(
            "ActivateReminderIntent completed. readBack=\(ReminderStateStore.shared.isReminderOn)"
        )
        return .result(dialog: IntentDialog("Reminder activated in La Suite."))
    }
}
