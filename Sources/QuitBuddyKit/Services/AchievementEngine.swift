import Foundation

public struct AchievementEngine: Sendable {
    private let milestones: [Milestone]
    private let calendar: Calendar
    private let metricsCalculator: MetricsCalculator

    public init(
        milestones: [Milestone] = Milestone.defaultMilestones,
        calendar: Calendar = .quitBuddy
    ) {
        self.milestones = milestones
        self.calendar = calendar
        self.metricsCalculator = MetricsCalculator(calendar: calendar)
    }

    public func earnedAchievements(
        plan: QuitPlan,
        events: [CravingEvent],
        asOf date: Date = Date()
    ) -> [Achievement] {
        let metrics = metricsCalculator.metrics(plan: plan, events: events, asOf: date)
        var achievements: [Achievement] = []

        for milestone in milestones {
            if metrics.smokeFreeDays >= milestone.days {
                let achievementDate = calendar.date(byAdding: .day, value: milestone.days, to: calendar.startOfDay(for: plan.startDate)) ?? date
                achievements.append(
                    Achievement(
                        kind: .milestoneDay,
                        title: milestone.title,
                        achievedOn: min(achievementDate, date),
                        metadata: ["days": String(milestone.days)]
                    )
                )
            }
        }

        if metrics.consecutiveSmokeFreeDays >= 7 {
            let achievementDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: date)) ?? date
            achievements.append(
                Achievement(
                    kind: .consecutiveSeven,
                    title: "Seven consecutive smoke-free days",
                    achievedOn: achievementDate
                )
            )
        }

        achievements.sort(by: { $0.achievedOn < $1.achievedOn })
        return achievements
    }
}
