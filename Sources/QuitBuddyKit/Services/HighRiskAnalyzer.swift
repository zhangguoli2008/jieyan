import Foundation

public struct HighRiskWindow: Codable, Equatable, Sendable {
    public var start: DateComponents
    public var end: DateComponents
    public var reminder: DateComponents
    public var triggerCount: Int
    public var triggers: [CravingTrigger]

    public init(
        start: DateComponents,
        end: DateComponents,
        reminder: DateComponents,
        triggerCount: Int,
        triggers: [CravingTrigger]
    ) {
        self.start = start
        self.end = end
        self.reminder = reminder
        self.triggerCount = triggerCount
        self.triggers = triggers
    }
}

public struct HighRiskAnalyzer: Sendable {
    private let calendar: Calendar
    private let windowMinutes: Int
    private let leadMinutes: Int

    public init(calendar: Calendar = .quitBuddy, windowMinutes: Int = 60, leadMinutes: Int = 10) {
        self.calendar = calendar
        self.windowMinutes = max(windowMinutes, 15)
        self.leadMinutes = leadMinutes
    }

    public func topWindows(
        events: [CravingEvent],
        asOf date: Date = Date(),
        lookbackDays: Int = 7,
        limit: Int = 2
    ) -> [HighRiskWindow] {
        guard !events.isEmpty else { return [] }
        let cutoff = calendar.date(byAdding: .day, value: -lookbackDays, to: date) ?? date
        let recentEvents = events.filter { $0.timestamp >= cutoff }
        guard !recentEvents.isEmpty else { return [] }

        var buckets: [Int: (count: Int, triggers: [CravingTrigger])] = [:]
        for event in recentEvents {
            let components = calendar.dateComponents([.hour, .minute], from: event.timestamp)
            let minute = (components.minute ?? 0) / windowMinutes * windowMinutes
            let hour = components.hour ?? 0
            let bucketKey = hour * 60 + minute
            var entry = buckets[bucketKey] ?? (count: 0, triggers: [])
            entry.count += 1
            entry.triggers.append(event.trigger)
            buckets[bucketKey] = entry
        }

        let sortedBuckets = buckets.sorted { lhs, rhs in
            if lhs.value.count == rhs.value.count {
                return lhs.key < rhs.key
            }
            return lhs.value.count > rhs.value.count
        }

        return sortedBuckets.prefix(limit).map { bucket in
            let startTotalMinutes = bucket.key
            let startHour = startTotalMinutes / 60
            let startMinute = startTotalMinutes % 60
            let startComponents = DateComponents(hour: startHour, minute: startMinute)
            let endMinuteTotal = startTotalMinutes + windowMinutes
            let endHour = (endMinuteTotal / 60) % 24
            let endMinute = endMinuteTotal % 60
            let endComponents = DateComponents(hour: endHour, minute: endMinute)
            var reminderMinutes = startTotalMinutes - leadMinutes
            while reminderMinutes < 0 { reminderMinutes += 24 * 60 }
            let reminderHour = (reminderMinutes / 60) % 24
            let reminderMinute = reminderMinutes % 60
            let reminderComponents = DateComponents(hour: reminderHour, minute: reminderMinute)
            return HighRiskWindow(
                start: startComponents,
                end: endComponents,
                reminder: reminderComponents,
                triggerCount: bucket.value.count,
                triggers: bucket.value.triggers
            )
        }
    }
}
