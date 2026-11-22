import Foundation
import IdentifiedCollections
import Observation

/// One point on the session timeline: every open normal window at a moment in time.
struct TimelineSnapshot: Codable, Identifiable {
    let id: UUID
    let date: Date
    let windows: [SessionData]

    var tabs: [BrowserTab] {
        windows.flatMap { $0.ungroupedTabs + $0.tabGroups.flatMap(\.tabs) }
    }

    /// What the snapshot holds, ignoring transient tab state; two snapshots with the same
    /// signature look the same to the user.
    var signature: [String] {
        windows.flatMap { window in
            ["window"]
                + window.ungroupedTabs.map { "\($0.urlString)|\($0.title)" }
                + window.tabGroups.flatMap { group in
                    ["group|\(group.label)|\(group.color.rawValue)"]
                        + group.tabs.map { "\($0.urlString)|\($0.title)" }
                }
        }
    }
}

/// Keeps automatic snapshots of the open normal windows so they can be browsed and restored
/// from the Session Timeline. Stored in Application Support/Browser/timeline.json.
@MainActor
@Observable
final class TimelineStore {
    static let shared = TimelineStore()

    static let snapshotInterval: TimeInterval = 5 * 60
    static let maxAge: TimeInterval = 7 * 24 * 60 * 60
    static let maxCount = 500

    /// Newest first.
    private(set) var snapshots: [TimelineSnapshot] = []

    @ObservationIgnored private var isLoaded = false
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private let ioQueue = DispatchQueue(label: "Browser.TimelineStore", qos: .utility)

    private static var fileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("Browser", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("timeline.json")
    }

    private init() {
        let url = Self.fileURL
        ioQueue.async {
            let loaded = (try? Data(contentsOf: url))
                .flatMap { try? JSONDecoder().decode([TimelineSnapshot].self, from: $0) } ?? []
            DispatchQueue.main.async {
                MainActor.assumeIsolated { TimelineStore.shared.finishLoading(loaded) }
            }
        }
    }

    /// Starts taking a snapshot every five minutes while the app runs.
    func startAutosnapshots() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: Self.snapshotInterval, repeats: true) { _ in
            MainActor.assumeIsolated { TimelineStore.shared.snapshotOpenWindows() }
        }
        timer?.tolerance = 30
    }

    /// Records the current normal windows (private windows are never included).
    /// Call right before closing a window, a tab group or several tabs at once.
    func snapshotOpenWindows() {
        record(WindowRegistry.shared.normalWindowSessions())
    }

    func record(_ windows: [SessionData], at date: Date = Date()) {
        let snapshot = TimelineSnapshot(id: UUID(), date: date, windows: windows)
        // Skip snapshots with nothing worth restoring, or identical to the last one.
        guard snapshot.tabs.contains(where: { $0.url != nil }) else { return }
        guard snapshot.signature != snapshots.first?.signature else { return }
        snapshots.insert(snapshot, at: 0)
        prune()
        save()
    }

    func delete(_ id: UUID) {
        snapshots.removeAll { $0.id == id }
        save()
    }

    private func finishLoading(_ loaded: [TimelineSnapshot]) {
        // Snapshots taken before the file finished loading are newer than anything in it.
        snapshots = (snapshots + loaded).sorted { $0.date > $1.date }
        isLoaded = true
        prune()
        save()
    }

    private func prune() {
        let cutoff = Date().addingTimeInterval(-Self.maxAge)
        snapshots = Array(snapshots.filter { $0.date >= cutoff }.prefix(Self.maxCount))
    }

    /// Writes the timeline off the main thread. Waits until the file has been read so an
    /// early snapshot can't overwrite older history.
    private func save() {
        guard isLoaded else { return }
        let snapshots = snapshots
        let url = Self.fileURL
        ioQueue.async {
            guard let data = try? JSONEncoder().encode(snapshots) else { return }
            try? data.write(to: url, options: .atomic)
        }
    }
}

extension SessionData {
    /// A copy with new tab and group IDs, so a restored window never shares IDs with tabs
    /// that are still open elsewhere.
    func withFreshIDs() -> SessionData {
        var selected: UUID?
        func fresh(_ tab: BrowserTab) -> BrowserTab {
            let copy = BrowserTab(
                url: tab.url, title: tab.title, suggestedURL: tab.suggestedURL,
                isPinned: tab.isPinned, zoomLevel: tab.zoomLevel, faviconURL: tab.faviconURL
            )
            if tab.id == selectedTabId { selected = copy.id }
            return copy
        }
        let ungrouped = ungroupedTabs.map(fresh)
        let groups = tabGroups.map { group in
            TabGroup(
                label: group.label, color: group.color, isCollapsed: group.isCollapsed,
                tabs: IdentifiedArrayOf(uniqueElements: group.tabs.map(fresh))
            )
        }
        return SessionData(ungroupedTabs: ungrouped, tabGroups: groups, selectedTabId: selected, accentColor: accentColor)
    }
}
