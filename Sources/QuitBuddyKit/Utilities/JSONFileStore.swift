import Foundation

public actor JSONFileStore<Value: Codable> {
    private let url: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(url: URL) {
        self.url = url
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func load(default defaultValue: @autoclosure () -> Value) async -> Value {
        do {
            if let value = try await loadIfPresent() {
                return value
            } else {
                return defaultValue()
            }
        } catch {
            return defaultValue()
        }
    }

    public func loadIfPresent() async throws -> Value? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(Value.self, from: data)
    }

    public func save(_ value: Value) async throws {
        let data = try encoder.encode(value)
        try ensureDirectoryExists()
        try data.write(to: url, options: [.atomic])
    }

    public func remove() async throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }

    private func ensureDirectoryExists() throws {
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
}
