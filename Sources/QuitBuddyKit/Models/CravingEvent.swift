import Foundation

public enum CravingTrigger: String, Codable, CaseIterable, Sendable {
    case coffee
    case alcohol
    case stress
    case social
    case driving
    case solitude
    case boredom
    case other

    public var localizedTitle: String {
        switch self {
        case .coffee: return "Coffee"
        case .alcohol: return "Alcohol"
        case .stress: return "Stress"
        case .social: return "Social"
        case .driving: return "Commuting/Driving"
        case .solitude: return "Solitude"
        case .boredom: return "Boredom"
        case .other: return "Other"
        }
    }
}

public struct CravingEvent: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var timestamp: Date
    public var intensity: Int
    public var trigger: CravingTrigger
    public var didSmoke: Bool
    public var note: String?

    public init(
        id: UUID = UUID(),
        timestamp: Date,
        intensity: Int,
        trigger: CravingTrigger,
        didSmoke: Bool,
        note: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = max(1, min(intensity, 10))
        self.trigger = trigger
        self.didSmoke = didSmoke
        self.note = note
    }
}

public extension CravingEvent {
    func matches(query: String) -> Bool {
        let tokens = query
            .split(whereSeparator: { $0.isWhitespace })
            .map { $0.lowercased() }
        guard !tokens.isEmpty else { return true }
        let haystack = [
            trigger.rawValue,
            trigger.localizedTitle,
            note ?? "",
            didSmoke ? "smoked" : "resisted"
        ].joined(separator: " ").lowercased()
        return tokens.allSatisfy { haystack.contains($0) }
    }

    var didResist: Bool { !didSmoke }
}
