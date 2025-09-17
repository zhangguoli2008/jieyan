import Foundation

public struct Milestone: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var days: Int
    public var title: String
    public var achievedAt: Date?

    public init(id: UUID = UUID(), days: Int, title: String, achievedAt: Date? = nil) {
        self.id = id
        self.days = days
        self.title = title
        self.achievedAt = achievedAt
    }
}

public extension Milestone {
    static var defaultMilestones: [Milestone] {
        [3, 7, 14, 30, 90, 180, 365].map { days in
            Milestone(days: days, title: "Smoke-free for \(days) days")
        }
    }
}
