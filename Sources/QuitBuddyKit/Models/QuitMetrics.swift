import Foundation

public struct QuitMetrics: Codable, Equatable, Sendable {
    public var smokeFreeDays: Int
    public var moneySaved: Double
    public var cigarettesAvoided: Int
    public var minutesRecovered: Int
    public var consecutiveSmokeFreeDays: Int

    public init(
        smokeFreeDays: Int,
        moneySaved: Double,
        cigarettesAvoided: Int,
        minutesRecovered: Int,
        consecutiveSmokeFreeDays: Int
    ) {
        self.smokeFreeDays = smokeFreeDays
        self.moneySaved = moneySaved
        self.cigarettesAvoided = cigarettesAvoided
        self.minutesRecovered = minutesRecovered
        self.consecutiveSmokeFreeDays = consecutiveSmokeFreeDays
    }
}
