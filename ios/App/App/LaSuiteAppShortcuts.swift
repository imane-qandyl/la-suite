import AppIntents

struct LaSuiteAppShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .orange

    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ActivateReminderIntent(),
            phrases: [
                "Activate \(.applicationName)",
                "Turn on \(.applicationName)",
                "Enable \(.applicationName)",
                "Start \(.applicationName)",
                "Active \(.applicationName)",
                "Démarre \(.applicationName)",
                "Lance \(.applicationName)",
                "Ouvre \(.applicationName)",
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
