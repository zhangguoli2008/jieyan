import Foundation

public actor SettingsStore {
    private let store: JSONFileStore<UserSettings>

    public init(directory: URL) {
        self.store = JSONFileStore(url: directory.appendingPathComponent("user_settings.json"))
    }

    public func load() async -> UserSettings {
        await store.load(default: UserSettings())
    }

    public func save(_ settings: UserSettings) async throws {
        try await store.save(settings)
    }
}
