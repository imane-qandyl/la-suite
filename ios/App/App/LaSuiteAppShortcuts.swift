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
                "Rappelle-moi \(\.$timing) avec \(.applicationName)",
                "Rappelle-moi \(\.$timing) dans \(.applicationName)",
                "Prépare un rappel \(\.$timing) dans \(.applicationName)",
                "Prépare un rappel \(\.$timing) avec \(.applicationName)",
                "Remind me \(\.$timing) with \(.applicationName)",
            ],
            shortTitle: "Create Reminder",
            systemImageName: "calendar.badge.plus"
        )
    }
}
