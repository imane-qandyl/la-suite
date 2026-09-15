import AppIntents

struct LaSuiteAppShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .orange

    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ActivateReminderIntent(),
            phrases: [
                "Activate reminder in \(.applicationName)",
                "Activate reminder with \(.applicationName)",
                "Turn on reminder in \(.applicationName)",
                "Turn on reminder with \(.applicationName)",
                "Enable reminder in \(.applicationName)",
                "Activer le rappel dans \(.applicationName)",
                "Activer le rappel avec \(.applicationName)",
                "Active le rappel dans \(.applicationName)",
                "Active le rappel avec \(.applicationName)",
            ],
            shortTitle: "Activate Reminder",
            systemImageName: "bell.fill"
        )

        AppShortcut(
            intent: CreateReminderIntent(),
            phrases: [
                "Create reminder in \(.applicationName)",
                "Create a reminder in \(.applicationName)",
                "Créer un rappel dans \(.applicationName)",
                "Créer un rappel avec \(.applicationName)",
            ],
            shortTitle: "Create Reminder",
            systemImageName: "calendar.badge.plus"
        )
    }
}
