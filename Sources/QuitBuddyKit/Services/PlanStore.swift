import Foundation

public actor PlanStore {
    private let store: JSONFileStore<QuitPlan>

    public init(directory: URL) {
        self.store = JSONFileStore(url: directory.appendingPathComponent("quit_plan.json"))
    }

    public func load() async -> QuitPlan? {
        try? await store.loadIfPresent()
    }

    public func save(_ plan: QuitPlan) async throws {
        try await store.save(plan)
    }

    public func clear() async throws {
        try await store.remove()
    }
}
