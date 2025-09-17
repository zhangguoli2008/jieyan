import Foundation

public struct Achievement: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case milestoneDay
        case consecutiveSeven
    }

    public var id: UUID
    public var kind: Kind
    public var title: String
    public var achievedOn: Date
    public var metadata: [String: String]

    public init(
        id: UUID = UUID(),
        kind: Kind,
        title: String,
        achievedOn: Date,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.achievedOn = achievedOn
        self.metadata = metadata
    }
}
