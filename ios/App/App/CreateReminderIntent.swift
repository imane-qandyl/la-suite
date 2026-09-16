import AppIntents
import os

private let createReminderLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.lasuite.app",
    category: "CreateReminderIntent"
)

struct CreateReminderIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Reminder"
    static var description = IntentDescription(
        "Creates a reminder with text and a scheduled date and time in La Suite and Apple Reminders."
    )

    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = true

    @Parameter(
        title: "Reminder Text",
        description: "What you want to be reminded about, for example: Consulter le document de Marie",
        requestValueDialog: IntentDialog("What should I remind you about?")
    )
    var content: String

    @Parameter(
        title: "Date and Time",
        description: "When the reminder should alert, for example: tomorrow at 09:00",
        requestValueDialog: IntentDialog("When should I remind you?")
    )
    var date: Date

    static var parameterSummary: some ParameterSummary {
        Summary("Create reminder \(\.$content) at \(\.$date)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        createReminderLogger.info(
            "Performing CreateReminderIntent. content=\(self.content, privacy: .public) date=\(self.date.formatted(), privacy: .public)"
        )

        try await ReminderService.shared.createReminder(title: content, dueDate: date)

        ReminderStateStore.shared.setReminder(content: content, date: date, caller: "CreateReminderIntent.perform")
        ReminderStateStore.shared.setReminderOn(true, caller: "CreateReminderIntent.perform")

        createReminderLogger.info("CreateReminderIntent completed. readBack=\(ReminderStateStore.shared.isReminderOn)")

        let formattedDate = date.formatted(date: .complete, time: .shortened)
        return .result(dialog: IntentDialog("Reminder created: \(content) on \(formattedDate)."))
    }
}