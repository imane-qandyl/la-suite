import AppIntents
import os

private let createReminderLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.lasuite.app",
    category: "CreateReminderIntent"
)

struct CreateReminderIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Reminder"
    static var description = IntentDescription(
        "Creates a reminder in La Suite and Apple Reminders."
    )

    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = true

    // AppEnum — interpolated in the AppShortcut phrase.
    // Siri resolves this from the spoken phrase (e.g. "demain matin").
    @Parameter(
        title: "Timing",
        description: "When the reminder should alert — for example: demain matin"
    )
    var timing: ReminderTiming

    // Free-form String — NOT in the phrase.
    // Siri collects this via requestValueDialog after phrase match.
    @Parameter(
        title: "Reminder Text",
        description: "What you want to be reminded about",
        requestValueDialog: IntentDialog("Que dois-je vous rappeler ?")
    )
    var content: String

    static var parameterSummary: some ParameterSummary {
        Summary("Rappelle-moi \(\.$timing)") {
            \.$content
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        print("[INTENT] CreateReminderIntent.perform() START")
        createReminderLogger.info(
            "Performing CreateReminderIntent. timing=\(self.timing.rawValue, privacy: .public) content=\(self.content, privacy: .public)"
        )

        // Convert AppEnum → concrete Date using the local calendar.
        let resolvedDate = timing.resolvedDate

        createReminderLogger.info(
            "Resolved date: \(resolvedDate.formatted(), privacy: .public)"
        )

        try await ReminderService.shared.createReminder(title: content, dueDate: resolvedDate)

        ReminderStateStore.shared.setReminder(content: content, date: resolvedDate, caller: "CreateReminderIntent.perform")
        ReminderStateStore.shared.setReminderOn(true, caller: "CreateReminderIntent.perform")

        createReminderLogger.info(
            "CreateReminderIntent completed. readBack=\(ReminderStateStore.shared.isReminderOn)"
        )

        let formattedDate = resolvedDate.formatted(
            Date.FormatStyle().weekday(.wide).month().day().hour().minute()
        )
        return .result(dialog: IntentDialog("Rappel créé : \(content) — \(formattedDate)."))
    }
}
