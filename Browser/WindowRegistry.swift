import AppKit
import ComposableArchitecture
import Foundation

/// Tracks the open browser windows so the app can save every normal window's tabs on quit,
/// restore them on launch, and move tabs between windows.
@MainActor
final class WindowRegistry {
    static let shared = WindowRegistry()

    private struct Entry {
        let store: StoreOf<AppFeature>
        let isPrivate: Bool
    }

    private var entries: [Entry] = []
    private var pendingRestore: [SessionData]
    private var pendingOpens: [(data: SessionData, opened: (StoreOf<AppFeature>) -> Void)] = []
    /// Windows queued by the Session Timeline; each newly opened normal window claims one on appear.
    private var pendingTimelineRestore: [SessionData] = []

    private init() {
        pendingRestore = SessionStore.load()
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification, object: nil, queue: .main
        ) { _ in
            MainActor.assumeIsolated { WindowRegistry.shared.saveSession() }
        }
    }

    func register(_ store: StoreOf<AppFeature>, isPrivate: Bool) {
        guard !entries.contains(where: { $0.store === store }) else { return }
        entries.append(Entry(store: store, isPrivate: isPrivate))
    }

    func unregister(_ store: StoreOf<AppFeature>) {
        // Snapshot for the session timeline while the closing window is still listed.
        if entries.contains(where: { $0.store === store && !$0.isPrivate }) {
            TimelineStore.shared.snapshotOpenWindows()
        }
        // Closing the last normal window keeps its tabs for the next launch.
        let normal = entries.filter { !$0.isPrivate }
        if normal.count == 1, normal[0].store === store {
            saveSession()
        }
        entries.removeAll { $0.store === store }
    }

    /// Saved window state for the next window that opens at launch, if any is left.
    func nextPendingRestore() -> SessionData? {
        pendingRestore.isEmpty ? nil : pendingRestore.removeFirst()
    }

    var hasPendingRestore: Bool { !pendingRestore.isEmpty }

    /// Queues window contents (e.g. a workspace) for the next normal window that opens;
    /// `opened` receives that window's store.
    func enqueueOpen(_ data: SessionData, opened: @escaping (StoreOf<AppFeature>) -> Void) {
        pendingOpens.append((data, opened))
    }

    /// Hands the oldest queued contents, if any, to a newly opened window.
    func claimPendingOpen(for store: StoreOf<AppFeature>) -> SessionData? {
        guard !pendingOpens.isEmpty else { return nil }
        let open = pendingOpens.removeFirst()
        open.opened(store)
        return open.data
    }

    /// Queues windows to restore from the Session Timeline. Open one window afterwards;
    /// each window that claims an entry opens the next until the queue is empty.
    func queueTimelineRestore(_ windows: [SessionData]) {
        pendingTimelineRestore.append(contentsOf: windows)
    }

    func nextTimelineRestore() -> SessionData? {
        pendingTimelineRestore.isEmpty ? nil : pendingTimelineRestore.removeFirst()
    }

    var hasTimelineRestore: Bool { !pendingTimelineRestore.isEmpty }

    /// The store of another window holding `tabId`. Tabs only move between windows of the same kind.
    func store(owningTab tabId: UUID, isPrivate: Bool) -> StoreOf<AppFeature>? {
        entries.first { $0.isPrivate == isPrivate && $0.store.allTabs[id: tabId] != nil }?.store
    }

    /// The current state of every open normal window.
    func normalWindowSessions() -> [SessionData] {
        entries.filter { !$0.isPrivate }.map { entry in
            SessionData(
                ungroupedTabs: Array(entry.store.ungroupedTabs),
                tabGroups: Array(entry.store.tabGroups),
                selectedTabId: entry.store.selectedTabId,
                accentColor: entry.store.accentColor
            )
        }
    }

    func saveSession() {
        let windows = entries.filter { !$0.isPrivate }.map { entry in
            SessionData(
                ungroupedTabs: Array(entry.store.ungroupedTabs),
                tabGroups: Array(entry.store.tabGroups),
                selectedTabId: entry.store.selectedTabId,
                accentColor: entry.store.accentColor
            )
        }
        guard !windows.isEmpty else { return }
        SessionStore.save(windows)
    }
}
