import Foundation

public actor QuitBuddyController {
    public enum ControllerError: Error {
        case onboardingRequired
    }

    private let planStore: PlanStore
    private let cravingLog: CravingLog
    private let settingsStore: SettingsStore
    private let snapshotBridge: SharedSnapshotBridge
    private let metricsCalculator: MetricsCalculator
    private let achievementEngine: AchievementEngine
    private let highRiskAnalyzer: HighRiskAnalyzer
    private let notificationScheduler: NotificationScheduler
    private let encouragementGenerator: EncouragementGenerator

    public init(
        dataDirectory: URL,
        appGroupDirectory: URL,
        calendar: Calendar = .quitBuddy
    ) {
        self.planStore = PlanStore(directory: dataDirectory)
        self.cravingLog = CravingLog(directory: dataDirectory, calendar: calendar)
        self.settingsStore = SettingsStore(directory: dataDirectory)
        self.snapshotBridge = SharedSnapshotBridge(appGroupDirectory: appGroupDirectory)
        self.metricsCalculator = MetricsCalculator(calendar: calendar)
        self.achievementEngine = AchievementEngine(calendar: calendar)
        self.highRiskAnalyzer = HighRiskAnalyzer(calendar: calendar)
        self.notificationScheduler = NotificationScheduler(calendar: calendar, highRiskAnalyzer: highRiskAnalyzer)
        self.encouragementGenerator = EncouragementGenerator()
    }

    @discardableResult
    public func completeOnboarding(with plan: QuitPlan) async throws -> DashboardSummary {
        try await planStore.save(plan)
        return try await dashboard(asOf: Date())
    }

    public func updatePlan(_ plan: QuitPlan) async throws -> DashboardSummary {
        try await planStore.save(plan)
        return try await dashboard(asOf: Date())
    }

    public func loadPlan() async -> QuitPlan? {
        await planStore.load()
    }

    public func loadSettings() async -> UserSettings {
        await settingsStore.load()
    }

    public func updateSettings(_ settings: UserSettings) async throws {
        try await settingsStore.save(settings)
    }

    public func record(event: CravingEvent, date: Date = Date()) async throws -> (DashboardSummary, String) {
        guard let plan = await planStore.load() else {
            throw ControllerError.onboardingRequired
        }
        let updatedEvents = try await cravingLog.add(event)
        let summary = try await makeSummary(plan: plan, events: updatedEvents, asOf: date)
        let encouragement = encouragementGenerator.message(afterSaving: event, allEvents: updatedEvents, plan: plan)
        return (summary, encouragement)
    }

    public func dashboard(asOf date: Date = Date()) async throws -> DashboardSummary {
        guard let plan = await planStore.load() else {
            throw ControllerError.onboardingRequired
        }
        let events = await cravingLog.allEvents()
        return try await makeSummary(plan: plan, events: events, asOf: date)
    }

    public func exportCSV(month: DateComponents? = nil) async -> String {
        let events = await cravingLog.allEvents()
        return CSVExporter().export(events: events, month: month)
    }

    public func purgeAllData() async throws {
        try await planStore.clear()
        try await cravingLog.clear()
        try await settingsStore.save(UserSettings())
        try await snapshotBridge.updateSnapshot(metrics: QuitMetrics(
            smokeFreeDays: 0,
            moneySaved: 0,
            cigarettesAvoided: 0,
            minutesRecovered: 0,
            consecutiveSmokeFreeDays: 0
        ))
    }

    public func notificationRequests(asOf date: Date = Date()) async throws -> [LocalNotification] {
        guard let plan = await planStore.load() else {
            throw ControllerError.onboardingRequired
        }
        let events = await cravingLog.allEvents()
        let metrics = metricsCalculator.metrics(plan: plan, events: events, asOf: date)
        let settings = await settingsStore.load()
        var requests = notificationScheduler.dailyReminders(settings: settings.notificationSettings)
        if settings.notificationSettings.enableMilestones {
            requests += notificationScheduler.milestoneNotifications(plan: plan, metrics: metrics, referenceDate: date)
        }
        requests += notificationScheduler.highRiskReminders(
            events: events,
            settings: settings.notificationSettings,
            referenceDate: date
        )
        return deduplicate(requests: requests)
    }

    private func makeSummary(plan: QuitPlan, events: [CravingEvent], asOf date: Date) async throws -> DashboardSummary {
        let metrics = metricsCalculator.metrics(plan: plan, events: events, asOf: date)
        try await snapshotBridge.updateSnapshot(metrics: metrics, asOf: date)
        let achievements = achievementEngine.earnedAchievements(plan: plan, events: events, asOf: date)
        let settings = await settingsStore.load()
        let highRisk = highRiskAnalyzer.topWindows(
            events: events,
            asOf: date,
            lookbackDays: settings.notificationSettings.highRiskLookbackDays
        )
        let nextMilestone = Array(Milestone.defaultMilestones.filter { $0.days > metrics.smokeFreeDays }.prefix(1)).first
        let recent = Array(events.prefix(10))
        return DashboardSummary(
            plan: plan,
            metrics: metrics,
            nextMilestone: nextMilestone,
            achievements: achievements,
            highRiskWindows: highRisk,
            recentEvents: recent
        )
    }

    private func deduplicate(requests: [LocalNotification]) -> [LocalNotification] {
        var seen: Set<String> = []
        var result: [LocalNotification] = []
        for request in requests {
            if seen.insert(request.id).inserted {
                result.append(request)
            }
        }
        return result
    }
}
