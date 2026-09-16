import AppIntents
import Foundation

enum ReminderTiming: String, AppEnum {
    case tomorrowMorning = "demain matin"
    case tomorrowEvening = "demain soir"
    case today           = "aujourd'hui"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Timing")

    static var caseDisplayRepresentations: [ReminderTiming: DisplayRepresentation] = [
        .tomorrowMorning: DisplayRepresentation(title: "demain matin"),
        .tomorrowEvening: DisplayRepresentation(title: "demain soir"),
        .today:           DisplayRepresentation(title: "aujourd'hui"),
    ]

    /// Converts the enum case to a concrete `Date` using the current calendar.
    var resolvedDate: Date {
        let calendar = Calendar.current
        let now      = Date()
        let startOfToday = calendar.startOfDay(for: now)

        switch self {
        case .tomorrowMorning:
            // Tomorrow at 09:00
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow)!

        case .tomorrowEvening:
            // Tomorrow at 19:00
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: tomorrow)!

        case .today:
            // Same day, 1 hour from now, clamped to a sensible hour
            let oneHourLater = now.addingTimeInterval(3600)
            // If that pushes past 21:00 use 21:00 today instead
            let cap = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: startOfToday)!
            return oneHourLater < cap ? oneHourLater : cap
        }
    }
}
