import Foundation

struct SessionData: Codable {
    var ungroupedTabs: [BrowserTab]
    var tabGroups: [TabGroup]
    var selectedTabId: UUID?
    var accentColor: AccentColor
}

enum SessionStore {
    private static var fileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("Browser", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("session.json")
    }

    static func save(_ data: SessionData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        try? encoded.write(to: fileURL, options: .atomic)
    }

    static func load() -> SessionData? {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(SessionData.self, from: data) else { return nil }
        return decoded
    }
}
