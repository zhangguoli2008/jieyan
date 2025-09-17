import Foundation

public struct CSVExporter: Sendable {
    private let calendar: Calendar
    private let dateFormatter: DateFormatter

    public init(calendar: Calendar = .quitBuddy) {
        self.calendar = calendar
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_AU_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        self.dateFormatter = formatter
    }

    public func export(
        events: [CravingEvent],
        month: DateComponents? = nil
    ) -> String {
        var filtered = events
        if let month = month, let monthValue = month.month, let year = month.year {
            filtered = events.filter { event in
                let components = calendar.dateComponents([.year, .month], from: event.timestamp)
                return components.year == year && components.month == monthValue
            }
        }
        let header = "timestamp,intensity,trigger,didSmoke,note"
        let rows = filtered.sorted(by: { $0.timestamp < $1.timestamp }).map { event in
            [
                dateFormatter.string(from: event.timestamp),
                String(event.intensity),
                event.trigger.localizedTitle,
                event.didSmoke ? "true" : "false",
                escape(event.note ?? "")
            ].joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n")
    }

    private func escape(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("\n") else {
            return value
        }
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
