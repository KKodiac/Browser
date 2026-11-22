import AppKit
import ComposableArchitecture
import SwiftUI

/// An action the ⌘K command bar can run. Add new commands to `BrowserCommand.all`.
struct BrowserCommand: Identifiable {
    struct Context {
        let store: StoreOf<AppFeature>
        let openWindow: OpenWindowAction
    }

    let id: String
    let title: String
    let systemImage: String
    var shortcut: String? = nil
    /// Hides the command when it doesn't apply (e.g. "Unpin Tab" on an unpinned tab).
    var isAvailable: @MainActor (AppFeature.State) -> Bool = { _ in true }
    let run: @MainActor (Context) -> Void
}

extension BrowserCommand {
    static let all: [BrowserCommand] = [
        BrowserCommand(id: "newTab", title: "New Tab", systemImage: "plus.square", shortcut: "⌘T",
                       run: { $0.store.send(.addTab) }),
        BrowserCommand(id: "newWindow", title: "New Window", systemImage: "macwindow.badge.plus", shortcut: "⌘N",
                       run: { $0.openWindow(id: BrowserWindow.mainID) }),
        BrowserCommand(id: "newPrivateWindow", title: "New Private Window", systemImage: "eyeglasses", shortcut: "⇧⌘N",
                       run: { $0.openWindow(id: BrowserWindow.privateID) }),
        BrowserCommand(id: "closeTab", title: "Close Tab", systemImage: "xmark.square", shortcut: "⌘W",
                       run: { $0.store.send(.closeSelectedTab) }),
        BrowserCommand(id: "reopenClosedTab", title: "Reopen Closed Tab", systemImage: "arrow.uturn.backward", shortcut: "⇧⌘T",
                       run: { $0.store.send(.reopenClosedTab) }),
        BrowserCommand(id: "showBookmarks", title: "Show Bookmarks", systemImage: "sidebar.left", shortcut: "⇧⌘B",
                       run: { $0.store.send(.toggleBookmarksSidebar) }),
        BrowserCommand(id: "showHistory", title: "Show History", systemImage: "clock", shortcut: "⌘Y",
                       run: { $0.store.send(.toggleHistoryPanel) }),
        BrowserCommand(id: "showDownloads", title: "Show Downloads", systemImage: "arrow.down.circle", shortcut: "⇧⌘J",
                       run: { $0.store.send(.toggleDownloadsPopover) }),
        BrowserCommand(id: "find", title: "Find in Page", systemImage: "magnifyingglass", shortcut: "⌘F",
                       run: { context in
                           if !context.store.showFindBar { context.store.send(.toggleFindBar) }
                       }),
        BrowserCommand(id: "zoomIn", title: "Zoom In", systemImage: "plus.magnifyingglass", shortcut: "⌘+",
                       run: { $0.store.send(.zoomIn) }),
        BrowserCommand(id: "zoomOut", title: "Zoom Out", systemImage: "minus.magnifyingglass", shortcut: "⌘-",
                       run: { $0.store.send(.zoomOut) }),
        BrowserCommand(id: "actualSize", title: "Actual Size", systemImage: "1.magnifyingglass", shortcut: "⌘0",
                       run: { $0.store.send(.resetZoom) }),
        BrowserCommand(id: "toggleSplitView", title: "Toggle Split View", systemImage: "rectangle.split.2x1", shortcut: "⌘\\",
                       run: { $0.store.send(.toggleSplitView) }),
        BrowserCommand(id: "pinTab", title: "Pin Tab", systemImage: "pin",
                       isAvailable: { $0.selectedTab?.isPinned != true },
                       run: { $0.store.send(.togglePinTab($0.store.selectedId)) }),
        BrowserCommand(id: "unpinTab", title: "Unpin Tab", systemImage: "pin.slash",
                       isAvailable: { $0.selectedTab?.isPinned == true },
                       run: { $0.store.send(.togglePinTab($0.store.selectedId)) }),
        BrowserCommand(id: "addBookmark", title: "Add Bookmark", systemImage: "bookmark", shortcut: "⌘D",
                       run: { $0.store.send(.addBookmark) }),
    ]
}

/// One row in the command bar.
struct CommandBarItem: Identifiable {
    enum Kind: Equatable {
        case web, tab, command, bookmark, history

        var header: String? {
            switch self {
            case .web: return nil
            case .tab: return "Tabs"
            case .command: return "Commands"
            case .bookmark: return "Bookmarks"
            case .history: return "History"
            }
        }
    }

    enum Action {
        /// Text submitted as if typed into the URL bar.
        case web(String)
        case tab(UUID)
        case command(BrowserCommand)
        case url(URL)
    }

    let id: String
    let kind: Kind
    let title: String
    var subtitle: String? = nil
    let systemImage: String
    var shortcut: String? = nil
    let action: Action
}

/// Builds the command bar's result list: case-insensitive prefix matches before substring
/// matches, grouped as Tabs, Commands, Bookmarks, History, at most `limit` rows.
enum CommandBarSearch {
    static let limit = 12

    static func results(
        query: String,
        tabs: [BrowserTab],
        commands: [BrowserCommand],
        history: [HistoryEntry],
        bookmarks: [Bookmark]
    ) -> [CommandBarItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let q = trimmed.lowercased()

        let tabItems = ranked(tabs, query: q) { tab in
            [tab.displayTitle.lowercased()] + (tab.url.map { [SuggestionEngine.key(for: $0)] } ?? [])
        }.map { tab in
            CommandBarItem(id: "tab-\(tab.id)", kind: .tab, title: tab.displayTitle,
                           subtitle: tab.url?.absoluteString, systemImage: "square.on.square", action: .tab(tab.id))
        }
        let commandItems = ranked(commands, query: q) { [$0.title.lowercased()] }.map { command in
            CommandBarItem(id: "cmd-\(command.id)", kind: .command, title: command.title,
                           systemImage: command.systemImage, shortcut: command.shortcut, action: .command(command))
        }

        // History and bookmarks reuse the URL bar's matcher; popular sites aren't shown here.
        var bookmarkItems: [CommandBarItem] = []
        var historyItems: [CommandBarItem] = []
        if !q.isEmpty {
            let bookmarkKeys = Set(bookmarks.map { SuggestionEngine.key(for: $0.url) })
            for suggestion in SuggestionEngine.suggestions(for: q, history: history, bookmarks: bookmarks) {
                let title = suggestion.title.isEmpty ? (suggestion.url.host ?? suggestion.url.absoluteString) : suggestion.title
                if bookmarkKeys.contains(suggestion.id) {
                    bookmarkItems.append(CommandBarItem(id: "bookmark-\(suggestion.id)", kind: .bookmark, title: title,
                                                        subtitle: suggestion.url.absoluteString, systemImage: "bookmark",
                                                        action: .url(suggestion.url)))
                } else if suggestion.source == .history {
                    historyItems.append(CommandBarItem(id: "history-\(suggestion.id)", kind: .history, title: title,
                                                       subtitle: suggestion.url.absoluteString, systemImage: "clock",
                                                       action: .url(suggestion.url)))
                }
            }
        }

        let groups = [tabItems, commandItems, bookmarkItems, historyItems]
        var results: [CommandBarItem] = []

        // Offer "Go to" / "Search for" first unless some result matches the query exactly.
        if !q.isEmpty {
            let queryKey = URL(string: q).map(SuggestionEngine.key(for:)) ?? q
            let hasExactMatch = groups.joined().contains { item in
                if item.title.lowercased() == q { return true }
                if let subtitle = item.subtitle, let url = URL(string: subtitle) {
                    return SuggestionEngine.key(for: url) == queryKey
                }
                return false
            }
            if !hasExactMatch {
                let looksLikeURL = trimmed.contains(".") && !trimmed.contains(" ")
                results.append(CommandBarItem(
                    id: "web", kind: .web,
                    title: looksLikeURL ? "Go to \(trimmed)" : "Search for “\(trimmed)”",
                    systemImage: looksLikeURL ? "globe" : "magnifyingglass",
                    action: .web(trimmed)
                ))
            }
        }

        // Share the remaining rows round-robin so one large group can't crowd out the others.
        var taken = Array(repeating: 0, count: groups.count)
        var remaining = limit - results.count
        var progressed = true
        while remaining > 0 && progressed {
            progressed = false
            for i in groups.indices where remaining > 0 && taken[i] < groups[i].count {
                taken[i] += 1
                remaining -= 1
                progressed = true
            }
        }
        for (group, count) in zip(groups, taken) {
            results.append(contentsOf: group.prefix(count))
        }
        return results
    }

    /// Keeps elements with a field matching `query`, prefix matches first, otherwise in input order.
    /// An empty query keeps everything.
    private static func ranked<T>(_ elements: [T], query: String, fields: (T) -> [String]) -> [T] {
        guard !query.isEmpty else { return elements }
        let matches: [(rank: Int, index: Int, element: T)] = elements.enumerated().compactMap { index, element in
            let f = fields(element)
            if f.contains(where: { $0.hasPrefix(query) }) { return (0, index, element) }
            if f.contains(where: { $0.contains(query) }) { return (1, index, element) }
            return nil
        }
        return matches
            .sorted { ($0.rank, $0.index) < ($1.rank, $1.index) }
            .map(\.element)
    }
}

/// Floating ⌘K palette: searches open tabs, commands, bookmarks and history in one list.
struct CommandBar: View {
    let store: StoreOf<AppFeature>
    var onDismiss: () -> Void
    @Environment(BookmarkStore.self) private var bookmarkStore
    @Environment(HistoryStore.self) private var historyStore
    @Environment(\.openWindow) private var openWindow
    @State private var query = ""
    @State private var selectedIndex = 0
    @FocusState private var isFocused: Bool

    var body: some View {
        let items = CommandBarSearch.results(
            query: query,
            tabs: store.visualTabs,
            commands: BrowserCommand.all.filter { $0.isAvailable(store.state) },
            history: historyStore.entries,
            bookmarks: bookmarkStore.bookmarks
        )
        ZStack(alignment: .top) {
            // Clicking outside the palette closes it.
            Color.black.opacity(0.15)
                .contentShape(Rectangle())
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    TextField("Search tabs, commands, bookmarks and history", text: $query)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))
                        .focused($isFocused)
                        .onChange(of: query) { _, _ in selectedIndex = 0 }
                        .onKeyPress(.downArrow) {
                            selectedIndex = min(selectedIndex + 1, max(items.count - 1, 0))
                            return .handled
                        }
                        .onKeyPress(.upArrow) {
                            selectedIndex = max(selectedIndex - 1, 0)
                            return .handled
                        }
                        // ⌘-Return opens URLs in a new tab. Plain Return goes through onSubmit so input methods can commit first.
                        .onKeyPress(keys: [.return]) { press in
                            guard press.modifiers.contains(.command) else { return .ignored }
                            runSelected(items, newTab: true)
                            return .handled
                        }
                        .onSubmit { runSelected(items, newTab: NSEvent.modifierFlags.contains(.command)) }
                        .onExitCommand(perform: onDismiss)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                if !items.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            if index == 0 || items[index - 1].kind != item.kind, let header = item.kind.header {
                                Text(header)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.top, index == 0 ? 2 : 6)
                            }
                            Button {
                                run(item, newTab: NSEvent.modifierFlags.contains(.command))
                            } label: {
                                row(item, isSelected: index == selectedIndex)
                            }
                            .buttonStyle(.plain)
                            .onHover { hovering in
                                if hovering { selectedIndex = index }
                            }
                        }
                    }
                    .padding(6)
                }
            }
            .frame(width: 560)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
            .padding(.top, 80)
        }
        .onAppear { isFocused = true }
    }

    private func row(_ item: CommandBarItem, isSelected: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: item.systemImage)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 18)
            Text(item.title)
                .font(.system(size: 13))
                .lineLimit(1)
            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer(minLength: 0)
            if let shortcut = item.shortcut {
                Text(shortcut)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isSelected ? store.accentColor.color.opacity(0.30) : Color.clear)
        .clipShape(.rect(cornerRadius: 6, style: .continuous))
        .contentShape(Rectangle())
    }

    private func runSelected(_ items: [CommandBarItem], newTab: Bool) {
        guard items.indices.contains(selectedIndex) else { return }
        run(items[selectedIndex], newTab: newTab)
    }

    private func run(_ item: CommandBarItem, newTab: Bool) {
        onDismiss()
        switch item.action {
        case let .web(text):
            // Same as submitting the URL bar, optionally in a fresh tab.
            if newTab { store.send(.addTab) }
            store.send(.binding(.set(\.urlBarText, text)))
            store.send(.urlBarSubmitted)
        case let .tab(id):
            store.send(.selectTab(id))
        case let .command(command):
            command.run(BrowserCommand.Context(store: store, openWindow: openWindow))
        case let .url(url):
            if newTab {
                store.send(.openURLInNewTab(url, select: true))
            } else {
                store.send(.binding(.set(\.urlBarText, url.absoluteString)))
                store.send(.urlBarSubmitted)
            }
        }
    }
}
