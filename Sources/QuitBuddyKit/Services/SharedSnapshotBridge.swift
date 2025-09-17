import Foundation

public actor SharedSnapshotBridge {
    private let store: JSONFileStore<SharedSnapshot>

    public init(appGroupDirectory: URL) {
        self.store = JSONFileStore(url: appGroupDirectory.appendingPathComponent("shared_snapshot.json"))
    }

    @discardableResult
    public func updateSnapshot(metrics: QuitMetrics, asOf date: Date = Date()) async throws -> SharedSnapshot {
        let snapshot = SharedSnapshot(
            days: metrics.smokeFreeDays,
            money: metrics.moneySaved,
            updatedAt: date
        )
        try await store.save(snapshot)
        return snapshot
    }

    public func currentSnapshot() async -> SharedSnapshot? {
        try? await store.loadIfPresent()
    }
}
