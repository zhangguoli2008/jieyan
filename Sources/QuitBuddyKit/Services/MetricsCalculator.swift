import Foundation

public struct MetricsCalculator: Sendable {
    private let calendar: Calendar

    public init(calendar: Calendar = .quitBuddy) {
        self.calendar = calendar
    }

    public func metrics(
        plan: QuitPlan,
        events: [CravingEvent],
        asOf date: Date = Date()
    ) -> QuitMetrics {
        let smokeFreeDays = plan.daysSinceStart(asOf: date, calendar: calendar)
        let actualSmoked = events.filter { $0.didSmoke }.count
        let potentialCigarettes = plan.dailyBaseline * max(smokeFreeDays, 0)
        let avoided = max(potentialCigarettes - actualSmoked, 0)
        let moneySaved = avoided > 0
            ? (Double(avoided) / Double(plan.cigarettesPerPack)) * plan.pricePerPack.amount
            : 0
        let minutesRecovered = avoided * 8
        let consecutive = consecutiveSmokeFreeDays(events: events, asOf: date, planStart: plan.startDate)
        return QuitMetrics(
            smokeFreeDays: smokeFreeDays,
            moneySaved: moneySaved,
            cigarettesAvoided: avoided,
            minutesRecovered: minutesRecovered,
            consecutiveSmokeFreeDays: consecutive
        )
    }

    public func consecutiveSmokeFreeDays(
        events: [CravingEvent],
        asOf date: Date = Date(),
        planStart: Date? = nil
    ) -> Int {
        let dayStart = calendar.startOfDay(for: date)
        let smokeDates = events
            .filter { $0.didSmoke }
            .map { calendar.startOfDay(for: $0.timestamp) }
        if let lastSmokeDay = smokeDates.max() {
            guard lastSmokeDay < dayStart else { return 0 }
            let components = calendar.dateComponents([.day], from: lastSmokeDay, to: dayStart)
            return max((components.day ?? 0), 0)
        }

        if let planStart {
            let start = calendar.startOfDay(for: planStart)
            let components = calendar.dateComponents([.day], from: start, to: dayStart)
            return max(components.day ?? 0, 0)
        }

        if let earliestEvent = events.map({ $0.timestamp }).min() {
            let start = calendar.startOfDay(for: earliestEvent)
            let components = calendar.dateComponents([.day], from: start, to: dayStart)
            return max(components.day ?? 0, 0)
        }

        return 0
    }
}
