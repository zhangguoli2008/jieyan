import Foundation

public struct SharedSnapshot: Codable, Equatable, Sendable {
    public var days: Int
    public var money: Double
    public var updatedAt: Date

    public init(days: Int, money: Double, updatedAt: Date) {
        self.days = days
        self.money = money
        self.updatedAt = updatedAt
    }
}
