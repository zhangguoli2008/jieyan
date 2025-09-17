import Foundation

public struct AlternativeSuggestion: Codable, Equatable, Sendable, Identifiable {
    public var id: UUID
    public var title: String
    public var description: String

    public init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

public enum AlternativeSuggestionLibrary {
    public static let defaultSuggestions: [AlternativeSuggestion] = [
        AlternativeSuggestion(title: "Drink water", description: "Sip a glass of water slowly."),
        AlternativeSuggestion(title: "Go for a short walk", description: "Move for two minutes to reset."),
        AlternativeSuggestion(title: "Chew gum", description: "Keep your mouth busy with sugar-free gum."),
        AlternativeSuggestion(title: "Breathing break", description: "Complete a 1-minute 4-4-4-4 breath cycle."),
        AlternativeSuggestion(title: "Journal", description: "Write down what triggered this craving."),
        AlternativeSuggestion(title: "Call a friend", description: "Reach out to your support buddy."),
        AlternativeSuggestion(title: "Mindful stretch", description: "Stretch your shoulders and hands for one minute."),
        AlternativeSuggestion(title: "Healthy snack", description: "Eat a fruit or nuts to satisfy oral fixation.")
    ]
}
