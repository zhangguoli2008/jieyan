import Foundation

public struct QuitPlan: Codable, Equatable, Sendable {
    public enum Mode: String, Codable, CaseIterable, Sendable {
        case coldTurkey
        case gradual
    }

    public struct Price: Codable, Equatable, Sendable {
        public var amount: Double
        public var currencyDescription: String

        public init(amount: Double, currencyDescription: String) {
            self.amount = amount
            self.currencyDescription = currencyDescription
        }
    }

    public var id: UUID
    public var startDate: Date
    public var mode: Mode
    public var dailyBaseline: Int
    public var pricePerPack: Price
    public var cigarettesPerPack: Int

    public init(
        id: UUID = UUID(),
        startDate: Date,
        mode: Mode,
        dailyBaseline: Int,
        pricePerPack: Price,
        cigarettesPerPack: Int
    ) {
        self.id = id
        self.startDate = startDate
        self.mode = mode
        self.dailyBaseline = dailyBaseline
        self.pricePerPack = pricePerPack
        self.cigarettesPerPack = cigarettesPerPack
    }
}

public extension QuitPlan {
    func daysSinceStart(asOf date: Date, calendar: Calendar = Calendar.autoupdatingCurrent) -> Int {
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: date)
        guard let days = calendar.dateComponents([.day], from: start, to: end).day else {
            return 0
        }
        return max(days, 0)
    }
}
