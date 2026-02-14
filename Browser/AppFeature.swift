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
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        // Lifecycle
        case onAppear
        // Tab lifecycle
        case addTab
        case closeTab(UUID)
        case selectTab(UUID)
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
        // Accent color
        case setAccentColor(AccentColor)
        // WebView delegate callbacks
        case webViewNavigationStarted(tabId: UUID)
        case webViewNavigationFinished(tabId: UUID, url: URL?, title: String?, canGoBack: Bool, canGoForward: Bool)
        case webViewNavigationFailed(tabId: UUID, canGoBack: Bool, canGoForward: Bool)
        case webViewProvisionalNavigationFailed(tabId: UUID)
        case webViewLoadRequestConsumed(tabId: UUID)
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
                return .none

            case let .selectTab(tabId):
                state.selectedTabId = tabId
                if let t = state.allTabs[id: tabId] {
                    state.urlBarText = t.urlString
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
                    let query = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
                    url = URL(string: "https://www.google.com/search?q=\(query)")
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
                if let beforeTab {
                    if let idx = state.ungroupedTabs.index(id: beforeTab) {
                        state.ungroupedTabs.insert(tab, at: idx)
                    } else {
                        for groupIndex in state.tabGroups.indices {
                            if let idx = state.tabGroups[groupIndex].tabs.index(id: beforeTab) {
                                state.tabGroups[groupIndex].tabs.insert(tab, at: idx)
                                break
                            }
                        }
                    }
                } else {
                    state.ungroupedTabs.append(tab)
                }
                return .none

            // MARK: - Accent Color

            case let .setAccentColor(color):
                state.accentColor = color
                return .none

            // MARK: - WebView Delegate Callbacks

            case let .webViewNavigationStarted(tabId):
                updateTab(&state, id: tabId) { $0.isLoading = true }
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

            case let .webViewNavigationFailed(tabId, canGoBack, canGoForward):
                updateTab(&state, id: tabId) { tab in
                    tab.isLoading = false
                    tab.canGoBack = canGoBack
                    tab.canGoForward = canGoForward
                }
                return .none

            case let .webViewProvisionalNavigationFailed(tabId):
                updateTab(&state, id: tabId) { $0.isLoading = false }
                return .none

            case let .webViewLoadRequestConsumed(tabId):
                updateTab(&state, id: tabId) { $0.requestedLoad = false }
                return .none
            }
        }
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
