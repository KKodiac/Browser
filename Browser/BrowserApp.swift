import ComposableArchitecture
import SwiftUI

@main
struct BrowserApp: App {
    @FocusedValue(\.windowStore) private var store
    @Environment(\.openWindow) private var openWindow
    @State private var bookmarkStore = BookmarkStore()
    @State private var downloadManager = DownloadManager()
    @State private var historyStore = HistoryStore()
    @State private var workspaceStore = WorkspaceStore.shared

    init() {
        // The app restores its own windows from the saved session; turn off macOS window
        // restoration so windows aren't reopened twice.
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")
        TimelineStore.shared.startAutosnapshots()
    }

    /// Tab triage needs the on-device Foundation Models framework (macOS 26+).
    private static var supportsTabTriage: Bool {
        if #available(macOS 26.0, *) { return true }
        return false
    }

    var body: some Scene {
        WindowGroup(id: BrowserWindow.mainID) {
            BrowserWindow(isPrivate: false)
                .environment(bookmarkStore)
                .environment(downloadManager)
                .environment(historyStore)
        }
        .windowStyle(.automatic)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Window") {
                    openWindow(id: BrowserWindow.mainID)
                }
                .keyboardShortcut("n", modifiers: .command)
                Button("New Private Window") {
                    openWindow(id: BrowserWindow.privateID)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                Button("New Tab") {
                    store?.send(.addTab)
                }
                .keyboardShortcut("t", modifiers: .command)
            }
            CommandGroup(replacing: .saveItem) {
                Button("Close Tab") {
                    store?.send(.closeSelectedTab)
                }
                .keyboardShortcut("w", modifiers: .command)
                Button("Reopen Closed Tab") {
                    store?.send(.reopenClosedTab)
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
            CommandMenu("Tab") {
                Button("Select Next Tab") {
                    store?.send(.selectNextTab)
                }
                .keyboardShortcut(.tab, modifiers: .control)
                Button("Select Previous Tab") {
                    store?.send(.selectPreviousTab)
                }
                .keyboardShortcut(.tab, modifiers: [.control, .shift])
                Divider()
                ForEach(1..<9) { n in
                    Button("Select Tab \(n)") {
                        store?.send(.selectTabAtIndex(n - 1))
                    }
                    .keyboardShortcut(KeyEquivalent(Character("\(n)")), modifiers: .command)
                }
                Button("Select Last Tab") {
                    store?.send(.selectLastTab)
                }
                .keyboardShortcut("9", modifiers: .command)
                Divider()
                Button("Organize Tabs…") {
                    store?.send(.showTabTriage)
                }
                .keyboardShortcut("o", modifiers: [.command, .option])
                .disabled(!Self.supportsTabTriage)
            }
            CommandMenu("Navigation") {
                Button("Back") {
                    store?.send(.goBack)
                }
                .keyboardShortcut("[", modifiers: .command)
                Button("Forward") {
                    store?.send(.goForward)
                }
                .keyboardShortcut("]", modifiers: .command)
                Button("Reload") {
                    store?.send(.reload)
                }
                .keyboardShortcut("r", modifiers: .command)
                Divider()
                Button("Focus URL Bar") {
                    store?.send(.focusURLBar)
                }
                .keyboardShortcut("l", modifiers: .command)
                Button("Command Bar…") {
                    store?.send(.toggleCommandBar)
                }
                .keyboardShortcut("k", modifiers: .command)
            }
            CommandMenu("Bookmarks") {
                Button("Add Bookmark") {
                    store?.send(.addBookmark)
                }
                .keyboardShortcut("d", modifiers: .command)
                Button("Show Bookmarks") {
                    store?.send(.toggleBookmarksSidebar)
                }
                .keyboardShortcut("b", modifiers: [.command, .shift])
            }
            CommandMenu("Downloads") {
                Button("Show Downloads") {
                    store?.send(.toggleDownloadsPopover)
                }
                .keyboardShortcut("j", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .textEditing) {
                Button("Find...") {
                    store?.send(.toggleFindBar)
                }
                .keyboardShortcut("f", modifiers: .command)
            }
            CommandMenu("History") {
                Button("Show History") {
                    store?.send(.toggleHistoryPanel)
                }
                .keyboardShortcut("y", modifiers: .command)
                Button("Session Timeline…") {
                    store?.send(.binding(.set(\.showSessionTimeline, true)))
                }
                .keyboardShortcut("y", modifiers: [.command, .option])
            }
            CommandMenu("View") {
                Button("Zoom In") {
                    store?.send(.zoomIn)
                }
                .keyboardShortcut("+", modifiers: .command)
                Button("Zoom Out") {
                    store?.send(.zoomOut)
                }
                .keyboardShortcut("-", modifiers: .command)
                Button("Actual Size") {
                    store?.send(.resetZoom)
                }
                .keyboardShortcut("0", modifiers: .command)
                Divider()
                Button("Toggle Split View") {
                    store?.send(.toggleSplitView)
                }
                .keyboardShortcut("\\", modifiers: .command)
                Button("Ask This Page") {
                    store?.send(.toggleAskPage)
                }
                .keyboardShortcut("a", modifiers: [.command, .shift])
                .disabled(!askPageSupported)
            }
        }
        .commands {
            WorkspaceCommands(workspaceStore: workspaceStore)
        }

        Window("Workspaces", id: ManageWorkspacesView.windowID) {
            ManageWorkspacesView(workspaceStore: workspaceStore)
        }

        WindowGroup("Private Browsing", id: BrowserWindow.privateID) {
            BrowserWindow(isPrivate: true)
                .environment(bookmarkStore)
                .environment(downloadManager)
                .environment(historyStore)
        }
        .windowStyle(.automatic)

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }

    /// Ask This Page needs the Foundation Models framework (macOS 26+).
    private var askPageSupported: Bool {
        if #available(macOS 26.0, *) { return true }
        return false
    }
}
