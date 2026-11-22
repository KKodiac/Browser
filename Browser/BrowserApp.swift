import ComposableArchitecture
import SwiftUI

@main
struct BrowserApp: App {
    @State private var store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    @State private var bookmarkStore = BookmarkStore()
    @State private var downloadManager = DownloadManager()
    @State private var historyStore = HistoryStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .environment(bookmarkStore)
                .environment(downloadManager)
                .environment(historyStore)
                .frame(minWidth: 800, minHeight: 600)
                .onAppear { restoreSession() }
                .onDisappear { saveSession() }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                    saveSession()
                }
        }
        .windowStyle(.automatic)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Tab") {
                    store.send(.addTab)
                }
                .keyboardShortcut("t", modifiers: .command)
            }
            CommandGroup(replacing: .saveItem) {
                Button("Close Tab") {
                    store.send(.closeSelectedTab)
                }
                .keyboardShortcut("w", modifiers: .command)
                Button("Reopen Closed Tab") {
                    store.send(.reopenClosedTab)
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
            CommandMenu("Tab") {
                Button("Select Next Tab") {
                    store.send(.selectNextTab)
                }
                .keyboardShortcut(.tab, modifiers: .control)
                Button("Select Previous Tab") {
                    store.send(.selectPreviousTab)
                }
                .keyboardShortcut(.tab, modifiers: [.control, .shift])
                Divider()
                ForEach(1..<9) { n in
                    Button("Select Tab \(n)") {
                        store.send(.selectTabAtIndex(n - 1))
                    }
                    .keyboardShortcut(KeyEquivalent(Character("\(n)")), modifiers: .command)
                }
                Button("Select Last Tab") {
                    store.send(.selectLastTab)
                }
                .keyboardShortcut("9", modifiers: .command)
            }
            CommandMenu("Navigation") {
                Button("Back") {
                    store.send(.goBack)
                }
                .keyboardShortcut("[", modifiers: .command)
                Button("Forward") {
                    store.send(.goForward)
                }
                .keyboardShortcut("]", modifiers: .command)
                Button("Reload") {
                    store.send(.reload)
                }
                .keyboardShortcut("r", modifiers: .command)
                Divider()
                Button("Focus URL Bar") {
                    store.send(.focusURLBar)
                }
                .keyboardShortcut("l", modifiers: .command)
            }
            CommandMenu("Bookmarks") {
                Button("Add Bookmark") {
                    store.send(.addBookmark)
                }
                .keyboardShortcut("d", modifiers: .command)
                Button("Show Bookmarks") {
                    store.send(.toggleBookmarksSidebar)
                }
                .keyboardShortcut("b", modifiers: [.command, .shift])
            }
            CommandMenu("Downloads") {
                Button("Show Downloads") {
                    store.send(.toggleDownloadsPopover)
                }
                .keyboardShortcut("j", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .textEditing) {
                Button("Find...") {
                    store.send(.toggleFindBar)
                }
                .keyboardShortcut("f", modifiers: .command)
            }
            CommandMenu("History") {
                Button("Show History") {
                    store.send(.toggleHistoryPanel)
                }
                .keyboardShortcut("y", modifiers: .command)
            }
            CommandMenu("View") {
                Button("Zoom In") {
                    store.send(.zoomIn)
                }
                .keyboardShortcut("+", modifiers: .command)
                Button("Zoom Out") {
                    store.send(.zoomOut)
                }
                .keyboardShortcut("-", modifiers: .command)
                Button("Actual Size") {
                    store.send(.resetZoom)
                }
                .keyboardShortcut("0", modifiers: .command)
                Divider()
                Button("Toggle Split View") {
                    store.send(.toggleSplitView)
                }
                .keyboardShortcut("\\", modifiers: .command)
            }
        }

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }

    // MARK: - Session Persistence

    private func saveSession() {
        let data = SessionData(
            ungroupedTabs: Array(store.ungroupedTabs),
            tabGroups: Array(store.tabGroups),
            selectedTabId: store.selectedTabId,
            accentColor: store.accentColor
        )
        SessionStore.save(data)
    }

    private func restoreSession() {
        guard let data = SessionStore.load() else { return }
        guard !data.ungroupedTabs.isEmpty || !data.tabGroups.isEmpty else { return }
        store.send(.restoreSession(data))
    }
}
