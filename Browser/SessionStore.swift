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

    /// Saves one entry per normal window.
    static func save(_ windows: [SessionData]) {
        guard let encoded = try? JSONEncoder().encode(windows) else { return }
        try? encoded.write(to: fileURL, options: .atomic)
    }

    /// Loads the saved windows, skipping empty ones. Also reads the older single-window format.
    static func load() -> [SessionData] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        let windows = (try? decoder.decode([SessionData].self, from: data))
            ?? (try? decoder.decode(SessionData.self, from: data)).map { [$0] }
            ?? []
        return windows.filter { !$0.ungroupedTabs.isEmpty || !$0.tabGroups.isEmpty }
    }
}
