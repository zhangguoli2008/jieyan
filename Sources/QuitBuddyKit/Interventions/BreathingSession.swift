import Foundation

public struct BreathingPhase: Equatable, Sendable {
    public enum Kind: String, Sendable {
        case inhale
        case hold
        case exhale
        case rest
    }

    public var kind: Kind
    public var duration: TimeInterval

    public init(kind: Kind, duration: TimeInterval) {
        self.kind = kind
        self.duration = duration
    }
}

public struct BreathingSession: Equatable, Sendable {
    public var phases: [BreathingPhase]
    public var totalDuration: TimeInterval

    public static func boxBreathing(duration: TimeInterval = 60) -> BreathingSession {
        let basePhase = BreathingPhase(kind: .inhale, duration: 4)
        let cycle = [
            basePhase,
            BreathingPhase(kind: .hold, duration: 4),
            BreathingPhase(kind: .exhale, duration: 4),
            BreathingPhase(kind: .rest, duration: 4)
        ]
        var phases: [BreathingPhase] = []
        var accumulated: TimeInterval = 0
        while accumulated < duration {
            for phase in cycle {
                if accumulated >= duration { break }
                phases.append(phase)
                accumulated += phase.duration
            }
        }
        return BreathingSession(phases: phases, totalDuration: accumulated)
    }
}
