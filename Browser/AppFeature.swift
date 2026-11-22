import ComposableArchitecture
import Foundation
import IdentifiedCollections

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var ungroupedTabs: IdentifiedArrayOf<BrowserTab> = [BrowserTab()]
        var tabGroups: IdentifiedArrayOf<TabGroup> = []
        var selectedTabId: UUID?
        var urlBarText: String = ""
        var renamingGroupId: UUID?
        var renameText: String = ""
        var focusURLBarTrigger: Int = 0
        var focusRenameFieldTrigger: Int = 0
        var accentColor: AccentColor = .blue
        // Triggers (bridge TCA actions → local @State in ContentView)
        var addBookmarkTrigger: Int = 0
        var toggleBookmarksSidebarTrigger: Int = 0
        var toggleDownloadsPopoverTrigger: Int = 0
        var toggleHistoryPanelTrigger: Int = 0
        var toggleFindBarTrigger: Int = 0
        var toggleSplitViewTrigger: Int = 0
        // Find in page
        var findText: String = ""
        var findMatchCount: Int = 0
        var findMatchIndex: Int = 0
        var showFindBar: Bool = false
        var findNavigateTrigger: Int = 0
        var findNavigateStep: Int = 1
        // Split view
        var splitTabId: UUID?
        // Recently closed tabs (most recent last), bounded
        var closedTabs: [BrowserTab] = []

        var allTabs: IdentifiedArrayOf<BrowserTab> {
            var result = ungroupedTabs
            for group in tabGroups {
                result.append(contentsOf: group.tabs)
            }
            return result
        }

        var selectedTab: BrowserTab? {
            if let id = selectedTabId { return allTabs[id: id] }
            return allTabs.first
        }

        var selectedId: UUID {
            selectedTabId ?? allTabs.first!.id
        }

        /// Tabs in tab bar order: pinned, unpinned ungrouped, then grouped (unpinned).
        var visualTabs: [BrowserTab] {
            allTabs.filter(\.isPinned)
                + ungroupedTabs.filter { !$0.isPinned }
                + tabGroups.flatMap { $0.tabs.filter { !$0.isPinned } }
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        // Lifecycle
        case onAppear
        // Tab lifecycle
        case addTab
        case closeTab(UUID)
        case selectTab(UUID)
        case closeSelectedTab
        case reopenClosedTab
        case selectTabAtIndex(Int)
        case selectLastTab
        case selectNextTab
        case selectPreviousTab
        case openURLInNewTab(URL, select: Bool)
        // URL
        case urlBarSubmitted
        // Navigation commands
        case goBack
        case goForward
        case reload
        case focusURLBar
        // Group lifecycle
        case createGroup(from: UUID)
        case addTabToGroup(tabId: UUID, groupId: UUID)
        case removeTabFromGroup(UUID)
        case toggleGroupCollapse(UUID)
        case startRenamingGroup(UUID)
        case renameGroup(id: UUID, name: String)
        case changeGroupColor(id: UUID, color: GroupColor)
        case closeGroup(UUID)
        case ungroupAll(UUID)
        // Tab reorder
        case moveTab(id: UUID, beforeTab: UUID?)
        // Moving tabs between windows
        case detachTab(UUID)
        case insertTab(BrowserTab, beforeTab: UUID?)
        // Accent color
        case setAccentColor(AccentColor)
        // Session
        case restoreSession(SessionData)
        // Bookmarks (menu commands)
        case addBookmark
        case toggleBookmarksSidebar
        // Downloads
        case toggleDownloadsPopover
        // History
        case toggleHistoryPanel
        // Find in page
        case toggleFindBar
        case findNext
        case findPrevious
        case dismissFindBar
        case updateFindResults(matchCount: Int, matchIndex: Int)
        // Tab pinning
        case togglePinTab(UUID)
        // Zoom
        case zoomIn
        case zoomOut
        case resetZoom
        // Split view
        case toggleSplitView
        // Favicon
        case updateFavicon(tabId: UUID, faviconURL: URL?)
        // WebView delegate callbacks
        case webViewNavigationStarted(tabId: UUID)
        case webViewNavigationFinished(tabId: UUID, url: URL?, title: String?, canGoBack: Bool, canGoForward: Bool)
        case webViewNavigationFailed(tabId: UUID, canGoBack: Bool, canGoForward: Bool, errorMessage: String?)
        case webViewProvisionalNavigationFailed(tabId: UUID, errorMessage: String?)
        case webViewLoadRequestConsumed(tabId: UUID)
        case webViewProgressChanged(tabId: UUID, progress: Double)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                if state.selectedTabId == nil, let first = state.allTabs.first {
                    state.selectedTabId = first.id
                    state.urlBarText = first.suggestedURL
                }
                return .none

            // MARK: - Tab Lifecycle

            case .addTab:
                let tab = BrowserTab()
                state.ungroupedTabs.append(tab)
                state.selectedTabId = tab.id
                state.urlBarText = ""
                return .none

            case let .closeTab(tabId):
                if let closed = state.allTabs[id: tabId], closed.url != nil {
                    state.closedTabs.append(closed)
                    if state.closedTabs.count > 20 {
                        state.closedTabs.removeFirst()
                    }
                }
                removeTab(&state, id: tabId)
                return .none

            case let .selectTab(tabId):
                state.selectedTabId = tabId
                if let t = state.allTabs[id: tabId] {
                    state.urlBarText = t.urlString
                }
                return .none

            case .closeSelectedTab:
                return .send(.closeTab(state.selectedId))

            case .reopenClosedTab:
                guard let closed = state.closedTabs.popLast() else { return .none }
                let tab = BrowserTab(url: closed.url, title: closed.title, suggestedURL: closed.urlString)
                state.ungroupedTabs.append(tab)
                state.selectedTabId = tab.id
                state.urlBarText = tab.urlString
                return .none

            case let .selectTabAtIndex(index):
                let tabs = state.visualTabs
                guard tabs.indices.contains(index) else { return .none }
                return .send(.selectTab(tabs[index].id))

            case .selectLastTab:
                guard let last = state.visualTabs.last else { return .none }
                return .send(.selectTab(last.id))

            case .selectNextTab, .selectPreviousTab:
                let tabs = state.visualTabs
                guard !tabs.isEmpty else { return .none }
                let current = tabs.firstIndex { $0.id == state.selectedId } ?? 0
                var offset = -1
                if case .selectNextTab = action { offset = 1 }
                return .send(.selectTab(tabs[(current + offset + tabs.count) % tabs.count].id))

            case let .openURLInNewTab(url, select):
                let tab = BrowserTab(url: url, suggestedURL: url.absoluteString)
                state.ungroupedTabs.append(tab)
                if select {
                    state.selectedTabId = tab.id
                    state.urlBarText = url.absoluteString
                }
                return .none

            // MARK: - URL

            case .urlBarSubmitted:
                let trimmed = state.urlBarText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return .none }

                var url: URL?
                if trimmed.contains(".") && !trimmed.contains(" ") {
                    var str = trimmed
                    if !str.hasPrefix("http://") && !str.hasPrefix("https://") {
                        str = "https://" + str
                    }
                    url = URL(string: str)
                }
                if url == nil {
                    let engineRaw = UserDefaults.standard.string(forKey: "searchEngine") ?? SearchEngine.google.rawValue
                    let engine = SearchEngine(rawValue: engineRaw) ?? .google
                    let query = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
                    url = URL(string: "\(engine.searchURLPrefix)\(query)")
                }

                guard let u = url else { return .none }
                let selectedId = state.selectedId
                if state.ungroupedTabs[id: selectedId] != nil {
                    state.ungroupedTabs[id: selectedId]?.url = u
                    state.ungroupedTabs[id: selectedId]?.suggestedURL = u.absoluteString
                    state.ungroupedTabs[id: selectedId]?.requestedLoad = true
                } else {
                    for groupIndex in state.tabGroups.indices {
                        if state.tabGroups[groupIndex].tabs[id: selectedId] != nil {
                            state.tabGroups[groupIndex].tabs[id: selectedId]?.url = u
                            state.tabGroups[groupIndex].tabs[id: selectedId]?.suggestedURL = u.absoluteString
                            state.tabGroups[groupIndex].tabs[id: selectedId]?.requestedLoad = true
                            break
                        }
                    }
                }
                state.urlBarText = u.absoluteString
                return .none

            // MARK: - Navigation Commands

            case .goBack, .goForward, .reload:
                // These are handled by the view layer (WKWebView direct calls)
                return .none

            case .focusURLBar:
                state.focusURLBarTrigger += 1
                return .none

            // MARK: - Group Lifecycle

            case let .createGroup(from: tabId):
                guard let tab = state.ungroupedTabs[id: tabId] else { return .none }
                state.ungroupedTabs.remove(id: tabId)
                let group = TabGroup(tabs: [tab])
                state.tabGroups.append(group)
                return .none

            case let .addTabToGroup(tabId, groupId):
                guard let tab = state.ungroupedTabs[id: tabId] else { return .none }
                state.ungroupedTabs.remove(id: tabId)
                state.tabGroups[id: groupId]?.tabs.append(tab)
                return .none

            case let .removeTabFromGroup(tabId):
                var removedTab: BrowserTab?
                for index in state.tabGroups.indices {
                    if let tab = state.tabGroups[index].tabs[id: tabId] {
                        removedTab = tab
                        state.tabGroups[index].tabs.remove(id: tabId)
                        break
                    }
                }
                state.tabGroups.removeAll { $0.tabs.isEmpty }
                if let tab = removedTab {
                    state.ungroupedTabs.append(tab)
                }
                return .none

            case let .toggleGroupCollapse(groupId):
                state.tabGroups[id: groupId]?.isCollapsed.toggle()
                return .none

            case let .startRenamingGroup(groupId):
                guard let group = state.tabGroups[id: groupId] else { return .none }
                state.renameText = group.label
                state.renamingGroupId = groupId
                state.focusRenameFieldTrigger += 1
                return .none

            case let .renameGroup(id, name):
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    state.tabGroups[id: id]?.label = trimmed
                }
                state.renamingGroupId = nil
                return .none

            case let .changeGroupColor(id, color):
                state.tabGroups[id: id]?.color = color
                return .none

            case let .closeGroup(groupId):
                guard let group = state.tabGroups[id: groupId] else { return .none }
                let closingSelectedTab = group.tabs.contains { $0.id == state.selectedTabId }
                state.tabGroups.remove(id: groupId)

                if closingSelectedTab {
                    state.selectedTabId = state.allTabs.first?.id
                    if let t = state.allTabs.first {
                        state.urlBarText = t.urlString
                    }
                }
                if state.allTabs.isEmpty {
                    let newTab = BrowserTab()
                    state.ungroupedTabs.append(newTab)
                    state.selectedTabId = newTab.id
                    state.urlBarText = ""
                }
                return .none

            case let .ungroupAll(groupId):
                guard let group = state.tabGroups[id: groupId] else { return .none }
                state.ungroupedTabs.append(contentsOf: group.tabs)
                state.tabGroups.remove(id: groupId)
                return .none

            // MARK: - Tab Reorder

            case let .moveTab(id, beforeTab):
                // 1. Find and remove the tab from its current location
                var tab: BrowserTab?
                if let t = state.ungroupedTabs[id: id] {
                    tab = t
                    state.ungroupedTabs.remove(id: id)
                } else {
                    for groupIndex in state.tabGroups.indices {
                        if let t = state.tabGroups[groupIndex].tabs[id: id] {
                            tab = t
                            state.tabGroups[groupIndex].tabs.remove(id: id)
                            break
                        }
                    }
                }
                guard let tab else { return .none }

                // 2. Clean up empty groups
                state.tabGroups.removeAll { $0.tabs.isEmpty }

                // 3. Insert before beforeTab, or append to ungrouped if nil
                insert(tab, before: beforeTab, into: &state)
                return .none

            case let .detachTab(tabId):
                // The tab moves to another window, so it isn't added to recently closed tabs.
                removeTab(&state, id: tabId)
                return .none

            case let .insertTab(tab, beforeTab):
                insert(tab, before: beforeTab, into: &state)
                state.selectedTabId = tab.id
                state.urlBarText = tab.urlString
                return .none

            // MARK: - Accent Color

            case let .setAccentColor(color):
                state.accentColor = color
                UserDefaults.standard.set(color.rawValue, forKey: "accentColor")
                return .none

            case let .restoreSession(data):
                state.ungroupedTabs = IdentifiedArrayOf(uniqueElements: data.ungroupedTabs)
                state.tabGroups = IdentifiedArrayOf(uniqueElements: data.tabGroups)
                state.accentColor = data.accentColor
                if let selectedId = data.selectedTabId, state.allTabs[id: selectedId] != nil {
                    state.selectedTabId = selectedId
                } else {
                    state.selectedTabId = state.allTabs.first?.id
                }
                if let tab = state.selectedTab {
                    state.urlBarText = tab.urlString
                }
                if state.allTabs.isEmpty {
                    let newTab = BrowserTab()
                    state.ungroupedTabs.append(newTab)
                    state.selectedTabId = newTab.id
                    state.urlBarText = ""
                }
                return .none

            // MARK: - Bookmarks

            case .addBookmark:
                state.addBookmarkTrigger += 1
                return .none

            case .toggleBookmarksSidebar:
                state.toggleBookmarksSidebarTrigger += 1
                return .none

            case .toggleDownloadsPopover:
                state.toggleDownloadsPopoverTrigger += 1
                return .none

            // MARK: - History

            case .toggleHistoryPanel:
                state.toggleHistoryPanelTrigger += 1
                return .none

            // MARK: - Find in Page

            case .toggleFindBar:
                state.showFindBar.toggle()
                if !state.showFindBar {
                    state.findText = ""
                    state.findMatchCount = 0
                    state.findMatchIndex = 0
                }
                state.toggleFindBarTrigger += 1
                return .none

            case .findNext:
                state.findNavigateStep = 1
                state.findNavigateTrigger += 1
                return .none

            case .findPrevious:
                state.findNavigateStep = -1
                state.findNavigateTrigger += 1
                return .none

            case .dismissFindBar:
                state.showFindBar = false
                state.findText = ""
                state.findMatchCount = 0
                state.findMatchIndex = 0
                return .none

            case let .updateFindResults(matchCount, matchIndex):
                state.findMatchCount = matchCount
                state.findMatchIndex = matchIndex
                return .none

            // MARK: - Tab Pinning

            case let .togglePinTab(tabId):
                updateTab(&state, id: tabId) { $0.isPinned.toggle() }
                return .none

            // MARK: - Zoom

            case .zoomIn:
                let id = state.selectedId
                updateTab(&state, id: id) { $0.zoomLevel = min($0.zoomLevel + 0.1, 3.0) }
                return .none

            case .zoomOut:
                let id = state.selectedId
                updateTab(&state, id: id) { $0.zoomLevel = max($0.zoomLevel - 0.1, 0.3) }
                return .none

            case .resetZoom:
                let id = state.selectedId
                updateTab(&state, id: id) { $0.zoomLevel = 1.0 }
                return .none

            // MARK: - Split View

            case .toggleSplitView:
                if state.splitTabId != nil {
                    state.splitTabId = nil
                } else {
                    // Pick first tab that isn't the selected one
                    let other = state.allTabs.first { $0.id != state.selectedId }
                    state.splitTabId = other?.id
                }
                state.toggleSplitViewTrigger += 1
                return .none

            // MARK: - Favicon

            case let .updateFavicon(tabId, faviconURL):
                updateTab(&state, id: tabId) { $0.faviconURL = faviconURL }
                return .none

            // MARK: - WebView Delegate Callbacks

            case let .webViewNavigationStarted(tabId):
                updateTab(&state, id: tabId) { tab in
                    tab.isLoading = true
                    tab.loadError = nil
                }
                return .none

            case let .webViewNavigationFinished(tabId, url, title, canGoBack, canGoForward):
                updateTab(&state, id: tabId) { tab in
                    tab.isLoading = false
                    if let url { tab.url = url }
                    if let title { tab.title = title }
                    tab.canGoBack = canGoBack
                    tab.canGoForward = canGoForward
                    if let url { tab.suggestedURL = url.absoluteString }
                }
                if tabId == state.selectedId, let url {
                    state.urlBarText = url.absoluteString
                }
                return .none

            case let .webViewNavigationFailed(tabId, canGoBack, canGoForward, errorMessage):
                updateTab(&state, id: tabId) { tab in
                    tab.isLoading = false
                    tab.loadError = errorMessage
                    tab.canGoBack = canGoBack
                    tab.canGoForward = canGoForward
                }
                return .none

            case let .webViewProvisionalNavigationFailed(tabId, errorMessage):
                updateTab(&state, id: tabId) { tab in
                    tab.isLoading = false
                    tab.loadError = errorMessage
                }
                return .none

            case let .webViewLoadRequestConsumed(tabId):
                updateTab(&state, id: tabId) { $0.requestedLoad = false }
                return .none

            case let .webViewProgressChanged(tabId, progress):
                updateTab(&state, id: tabId) { $0.estimatedProgress = progress }
                return .none
            }
        }
    }

    /// Removes a tab, drops groups it leaves empty, fixes the selection, and keeps at least one tab open.
    private func removeTab(_ state: inout State, id tabId: UUID) {
        state.ungroupedTabs.remove(id: tabId)
        for index in state.tabGroups.indices {
            state.tabGroups[index].tabs.remove(id: tabId)
        }
        state.tabGroups.removeAll { $0.tabs.isEmpty }

        if state.selectedTabId == tabId {
            state.selectedTabId = state.allTabs.first?.id
            if let t = state.allTabs.first {
                state.urlBarText = t.urlString
            }
        }
        if state.allTabs.isEmpty {
            let newTab = BrowserTab()
            state.ungroupedTabs.append(newTab)
            state.selectedTabId = newTab.id
            state.urlBarText = ""
        }
    }

    /// Inserts a tab before `beforeTab` (in whichever group holds it), or appends it to the ungrouped tabs.
    private func insert(_ tab: BrowserTab, before beforeTab: UUID?, into state: inout State) {
        if let beforeTab {
            if let idx = state.ungroupedTabs.index(id: beforeTab) {
                state.ungroupedTabs.insert(tab, at: idx)
                return
            }
            for groupIndex in state.tabGroups.indices {
                if let idx = state.tabGroups[groupIndex].tabs.index(id: beforeTab) {
                    state.tabGroups[groupIndex].tabs.insert(tab, at: idx)
                    return
                }
            }
        }
        state.ungroupedTabs.append(tab)
    }

    private func updateTab(_ state: inout State, id: UUID, _ update: (inout BrowserTab) -> Void) {
        if state.ungroupedTabs[id: id] != nil {
            update(&state.ungroupedTabs[id: id]!)
        } else {
            for groupIndex in state.tabGroups.indices {
                if state.tabGroups[groupIndex].tabs[id: id] != nil {
                    update(&state.tabGroups[groupIndex].tabs[id: id]!)
                    return
                }
            }
        }
    }
}
