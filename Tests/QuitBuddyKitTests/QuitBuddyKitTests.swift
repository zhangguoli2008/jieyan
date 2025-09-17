import XCTest
@testable import QuitBuddyKit

final class QuitBuddyKitTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testMetricsCalculatorComputesSavings() {
        let plan = QuitPlan(
            startDate: calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!,
            mode: .coldTurkey,
            dailyBaseline: 10,
            pricePerPack: .init(amount: 25.0, currencyDescription: "AUD"),
            cigarettesPerPack: 20
        )
        let events: [CravingEvent] = (0..<5).map { offset in
            CravingEvent(
                timestamp: calendar.date(byAdding: .day, value: offset, to: plan.startDate)!,
                intensity: 5,
                trigger: .stress,
                didSmoke: offset == 3
            )
        }
        let metrics = MetricsCalculator(calendar: calendar).metrics(
            plan: plan,
            events: events,
            asOf: calendar.date(byAdding: .day, value: 7, to: plan.startDate)!
        )
        XCTAssertEqual(metrics.smokeFreeDays, 7)
        XCTAssertEqual(metrics.cigarettesAvoided, 69)
        XCTAssertEqual(metrics.minutesRecovered, 552)
        XCTAssertEqual(metrics.moneySaved, 86.25, accuracy: 0.01)
    }

    func testCravingLogFiltersAndCounts() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let log = CravingLog(directory: tempDir, calendar: calendar)
        let base = calendar.date(from: DateComponents(year: 2024, month: 2, day: 1, hour: 9))!
        try await log.add(CravingEvent(timestamp: base, intensity: 6, trigger: .coffee, didSmoke: false))
        try await log.add(CravingEvent(timestamp: calendar.date(byAdding: .hour, value: 1, to: base)!, intensity: 8, trigger: .stress, didSmoke: true))
        try await log.add(CravingEvent(timestamp: calendar.date(byAdding: .day, value: 1, to: base)!, intensity: 4, trigger: .social, didSmoke: false))

        let resisted = await log.recentResistedCount(days: 7, asOf: calendar.date(byAdding: .day, value: 2, to: base)!)
        XCTAssertEqual(resisted, 2)

        let filtered = await log.filteredEvents(filter: CravingFilter(triggers: [.coffee, .social], didSmoke: false))
        XCTAssertEqual(filtered.count, 2)

        let searchResults = await log.search(query: "stress")
        XCTAssertEqual(searchResults.count, 1)
    }

    func testHighRiskAnalyzerReturnsTopWindows() {
        let analyzer = HighRiskAnalyzer(calendar: calendar, windowMinutes: 60, leadMinutes: 10)
        let base = calendar.date(from: DateComponents(year: 2024, month: 3, day: 10, hour: 8, minute: 15))!
        var events: [CravingEvent] = []
        for day in 0..<5 {
            events.append(
                CravingEvent(timestamp: calendar.date(byAdding: .day, value: day, to: base)!, intensity: 7, trigger: .coffee, didSmoke: false)
            )
            events.append(
                CravingEvent(timestamp: calendar.date(byAdding: .day, value: day, to: base)!.addingTimeInterval(3600), intensity: 6, trigger: .stress, didSmoke: false)
            )
        }
        let windows = analyzer.topWindows(events: events, asOf: calendar.date(byAdding: .day, value: 6, to: base)!, lookbackDays: 7)
        XCTAssertFalse(windows.isEmpty)
        XCTAssertEqual(windows.first?.reminder.hour, 7)
        XCTAssertEqual(windows.first?.triggerCount, 5)
    }

    func testCSVExporterProducesExpectedFormat() {
        let exporter = CSVExporter(calendar: calendar)
        let timestamp = calendar.date(from: DateComponents(year: 2024, month: 4, day: 15, hour: 12, minute: 30))!
        let events = [
            CravingEvent(timestamp: timestamp, intensity: 9, trigger: .stress, didSmoke: false, note: "Deep breath"),
            CravingEvent(timestamp: timestamp.addingTimeInterval(3600), intensity: 3, trigger: .coffee, didSmoke: true, note: ""),
        ]
        let csv = exporter.export(events: events)
        let rows = csv.split(separator: "\n")
        XCTAssertEqual(rows.first, "timestamp,intensity,trigger,didSmoke,note")
        XCTAssertEqual(rows.count, 3)
        XCTAssertTrue(rows[1].contains("Deep breath"))
    }

    func testControllerOnboardingFlow() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let appGroup = tempDir.appendingPathComponent("app-group")
        let controller = QuitBuddyController(dataDirectory: tempDir, appGroupDirectory: appGroup, calendar: calendar)
        let plan = QuitPlan(
            startDate: calendar.date(from: DateComponents(year: 2024, month: 5, day: 1))!,
            mode: .coldTurkey,
            dailyBaseline: 12,
            pricePerPack: .init(amount: 30, currencyDescription: "AUD"),
            cigarettesPerPack: 20
        )
        _ = try await controller.completeOnboarding(with: plan)

        let event = CravingEvent(
            timestamp: calendar.date(from: DateComponents(year: 2024, month: 5, day: 1, hour: 9))!,
            intensity: 6,
            trigger: .coffee,
            didSmoke: false
        )
        let (summary, encouragement) = try await controller.record(event: event)
        XCTAssertFalse(encouragement.isEmpty)
        XCTAssertEqual(summary.plan, plan)
        XCTAssertEqual(summary.recentEvents.count, 1)

        let notifications = try await controller.notificationRequests(asOf: calendar.date(from: DateComponents(year: 2024, month: 5, day: 2))!)
        XCTAssertFalse(notifications.isEmpty)
    }
}
