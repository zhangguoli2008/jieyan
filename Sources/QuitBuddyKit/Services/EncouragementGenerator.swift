import Foundation

public struct EncouragementGenerator: Sendable {
    public init() {}

    public func message(afterSaving event: CravingEvent, allEvents: [CravingEvent], plan: QuitPlan?) -> String {
        if event.didResist {
            let resistedCount = allEvents.filter { $0.didResist }.count
            if resistedCount == 1 {
                return "👏 Great start! You resisted your first craving."
            } else {
                return "👏 Already resisted \(resistedCount) cravings!"
            }
        } else {
            let planStart = plan?.startDate
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            if let planStart, let planDays = plan?.daysSinceStart(asOf: Date(), calendar: .quitBuddy) {
                return "It's okay to slip. You've still been at it since \(formatter.string(from: planStart)). Tap reset to continue your \(planDays)-day journey."
            } else {
                return "Log it and restart when you're ready. Tomorrow is a new chance."
            }
        }
    }
}
