import Foundation

public struct LocalNotification: Codable, Equatable, Sendable {
    public var id: String
    public var title: String
    public var body: String
    public var fireDate: DateComponents
    public var repeats: Bool

    public init(id: String, title: String, body: String, fireDate: DateComponents, repeats: Bool) {
        self.id = id
        self.title = title
        self.body = body
        self.fireDate = fireDate
        self.repeats = repeats
    }
}

public struct NotificationScheduler: Sendable {
    private let calendar: Calendar
    private let highRiskAnalyzer: HighRiskAnalyzer

    public init(calendar: Calendar = .quitBuddy, highRiskAnalyzer: HighRiskAnalyzer? = nil) {
        self.calendar = calendar
        self.highRiskAnalyzer = highRiskAnalyzer ?? HighRiskAnalyzer(calendar: calendar)
    }

    public func dailyReminders(settings: NotificationSettings) -> [LocalNotification] {
        settings.reminderTimes.enumerated().map { index, components in
            let id = "daily-reminder-\(index)"
            var fireDate = components
            fireDate.calendar = calendar
            return LocalNotification(
                id: id,
                title: "Stay smoke-free",
                body: "Take a mindful breath and remember your goal.",
                fireDate: fireDate,
                repeats: true
            )
        }
    }

    public func milestoneNotifications(
        plan: QuitPlan,
        metrics: QuitMetrics,
        referenceDate: Date = Date()
    ) -> [LocalNotification] {
        guard metrics.smokeFreeDays >= 0 else { return [] }
        let milestoneStart = calendar.startOfDay(for: plan.startDate)
        let today = calendar.startOfDay(for: referenceDate)
        let upcomingMilestones = Milestone.defaultMilestones.filter { milestone in
            guard let fireDate = calendar.date(byAdding: .day, value: milestone.days, to: milestoneStart) else { return false }
            return fireDate >= today
        }
        return Array(upcomingMilestones.prefix(3)).compactMap { milestone in
            guard let fireDate = calendar.date(byAdding: .day, value: milestone.days, to: milestoneStart) else { return nil }
            var components = calendar.dateComponents([.year, .month, .day], from: fireDate)
            components.calendar = calendar
            components.hour = 9
            components.minute = 30
            return LocalNotification(
                id: "milestone-\(milestone.days)",
                title: "Milestone reached",
                body: "Congratulations on \(milestone.days) days smoke-free! Keep going.",
                fireDate: components,
                repeats: false
            )
        }
    }

    public func highRiskReminders(
        events: [CravingEvent],
        settings: NotificationSettings,
        referenceDate: Date = Date()
    ) -> [LocalNotification] {
        let windows = highRiskAnalyzer.topWindows(
            events: events,
            asOf: referenceDate,
            lookbackDays: settings.highRiskLookbackDays
        )
        return windows.enumerated().map { index, window in
            var components = window.reminder
            components.calendar = calendar
            let triggerList = window.triggers.reduce(into: [CravingTrigger: Int]()) { counts, trigger in
                counts[trigger, default: 0] += 1
            }
            let sortedTriggers = triggerList.sorted { $0.value > $1.value }
            let body: String
            if let topTrigger = sortedTriggers.first {
                body = "Likely craving ahead (~\(topTrigger.key.localizedTitle)). Prepare a micro-intervention."
            } else {
                body = "Likely craving ahead. Prepare a micro-intervention."
            }
            return LocalNotification(
                id: "high-risk-\(index)",
                title: "Check-in before cravings hit",
                body: body,
                fireDate: components,
                repeats: true
            )
        }
    }
}
