import Foundation

public struct DashboardSummary: Sendable, Equatable {
    public var plan: QuitPlan
    public var metrics: QuitMetrics
    public var nextMilestone: Milestone?
    public var achievements: [Achievement]
    public var highRiskWindows: [HighRiskWindow]
    public var recentEvents: [CravingEvent]

    public init(
        plan: QuitPlan,
        metrics: QuitMetrics,
        nextMilestone: Milestone?,
        achievements: [Achievement],
        highRiskWindows: [HighRiskWindow],
        recentEvents: [CravingEvent]
    ) {
        self.plan = plan
        self.metrics = metrics
        self.nextMilestone = nextMilestone
        self.achievements = achievements
        self.highRiskWindows = highRiskWindows
        self.recentEvents = recentEvents
    }
}
