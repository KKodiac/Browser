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

    /// The store of another window holding `tabId`. Tabs only move between windows of the same kind.
    func store(owningTab tabId: UUID, isPrivate: Bool) -> StoreOf<AppFeature>? {
        entries.first { $0.isPrivate == isPrivate && $0.store.allTabs[id: tabId] != nil }?.store
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
