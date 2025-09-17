import Foundation

public struct CravingFilter: Sendable {
    public var triggers: Set<CravingTrigger>?
    public var didSmoke: Bool?

    public init(triggers: Set<CravingTrigger>? = nil, didSmoke: Bool? = nil) {
        self.triggers = triggers
        self.didSmoke = didSmoke
    }

    func matches(event: CravingEvent) -> Bool {
        if let triggers = triggers, !triggers.isEmpty, !triggers.contains(event.trigger) {
            return false
        }
        if let didSmoke = didSmoke, event.didSmoke != didSmoke {
            return false
        }
        return true
    }
}

public actor CravingLog {
    private let store: JSONFileStore<[CravingEvent]>
    private let calendar: Calendar
    private let retentionLimit: Int

    public init(directory: URL, calendar: Calendar = .quitBuddy, retentionLimit: Int = 1000) {
        self.store = JSONFileStore(url: directory.appendingPathComponent("craving_events.json"))
        self.calendar = calendar
        self.retentionLimit = retentionLimit
    }

    public func allEvents() async -> [CravingEvent] {
        let events = await store.load(default: [])
        return events.sorted(by: { $0.timestamp > $1.timestamp })
    }

    @discardableResult
    public func add(_ event: CravingEvent) async throws -> [CravingEvent] {
        var events = await store.load(default: [])
        events.append(event)
        events.sort(by: { $0.timestamp > $1.timestamp })
        if events.count > retentionLimit {
            events = Array(events.prefix(retentionLimit))
        }
        try await store.save(events)
        return events
    }

    public func remove(id: UUID) async throws {
        var events = await store.load(default: [])
        let originalCount = events.count
        events.removeAll { $0.id == id }
        guard events.count != originalCount else { return }
        try await store.save(events)
    }

    public func clear() async throws {
        try await store.remove()
    }

    public func search(query: String, filter: CravingFilter = CravingFilter()) async -> [CravingEvent] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else {
            return await filteredEvents(filter: filter)
        }
        let events = await store.load(default: [])
        return events
            .filter { filter.matches(event: $0) }
            .filter { $0.matches(query: normalizedQuery) }
            .sorted(by: { $0.timestamp > $1.timestamp })
    }

    public func filteredEvents(filter: CravingFilter = CravingFilter()) async -> [CravingEvent] {
        let events = await store.load(default: [])
        return events
            .filter { filter.matches(event: $0) }
            .sorted(by: { $0.timestamp > $1.timestamp })
    }

    public func recentResistedCount(days: Int, asOf date: Date = Date()) async -> Int {
        let cutoff = calendar.date(byAdding: .day, value: -days, to: date) ?? date
        let events = await store.load(default: [])
        return events.filter { $0.didResist && $0.timestamp >= cutoff }.count
    }

    public func consecutiveSmokeFreeDays(asOf date: Date = Date()) async -> Int {
        let events = await store.load(default: [])
        return MetricsCalculator(calendar: calendar).consecutiveSmokeFreeDays(events: events, asOf: date)
    }
}
