import Foundation

public extension Calendar {
    static var quitBuddy: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.autoupdatingCurrent
        calendar.timeZone = TimeZone.autoupdatingCurrent
        return calendar
    }

    func components(_ components: Set<Calendar.Component>, from start: Date, to end: Date) -> DateComponents {
        dateComponents(components, from: start, to: end)
    }
}
