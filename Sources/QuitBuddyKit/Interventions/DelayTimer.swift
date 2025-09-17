import Foundation

public actor DelayTimer {
    public enum State: Equatable {
        case idle
        case running(remaining: TimeInterval)
        case paused(remaining: TimeInterval)
        case completed
    }

    private let totalDuration: TimeInterval
    private var remaining: TimeInterval
    private var state: State = .idle
    private var lastStartDate: Date?

    public init(duration: TimeInterval = 180) {
        self.totalDuration = duration
        self.remaining = duration
    }

    public func currentState() -> State {
        state
    }

    public func start(at date: Date = Date()) {
        guard case .idle = state else { return }
        state = .running(remaining: remaining)
        lastStartDate = date
    }

    public func pause(at date: Date = Date()) {
        guard case .running = state else { return }
        updateRemaining(for: date)
        state = .paused(remaining: remaining)
    }

    public func resume(at date: Date = Date()) {
        guard case .paused = state else { return }
        state = .running(remaining: remaining)
        lastStartDate = date
    }

    public func tick(to date: Date = Date()) {
        guard case .running = state else { return }
        updateRemaining(for: date)
        if remaining <= 0 {
            state = .completed
            remaining = 0
        } else {
            state = .running(remaining: remaining)
        }
    }

    public func reset() {
        remaining = totalDuration
        state = .idle
        lastStartDate = nil
    }

    private func updateRemaining(for date: Date) {
        guard let start = lastStartDate else { return }
        let elapsed = date.timeIntervalSince(start)
        remaining = max(0, remaining - elapsed)
        lastStartDate = date
    }
}
