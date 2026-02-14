import ComposableArchitecture
import SwiftUI
import WebKit

struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>
    @State private var currentWebView: WKWebView?
    @FocusState private var urlBarFocused: Bool
    @FocusState private var renameFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            contentArea
            urlBar
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: store.focusURLBarTrigger) { _, _ in
            urlBarFocused = true
        }
        .onChange(of: store.focusRenameFieldTrigger) { _, _ in
            renameFieldFocused = true
        }
    }

    // MARK: - URL Bar

    private var urlBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Button(action: { currentWebView?.goBack() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(store.selectedTab?.canGoBack != true)
                .opacity(store.selectedTab?.canGoBack == true ? 1 : 0.4)

                Button(action: { currentWebView?.goForward() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(store.selectedTab?.canGoForward != true)
                .opacity(store.selectedTab?.canGoForward == true ? 1 : 0.4)

                Button(action: { currentWebView?.reload() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(store.selectedTab?.isLoading == true)
            }

            TextField("Search or enter URL", text: $store.urlBarText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(.rect(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(nsColor: .separatorColor).opacity(0.6), lineWidth: 1)
                )
                .onSubmit {
                    store.send(.urlBarSubmitted)
                }
                .focused($urlBarFocused)

            if store.selectedTab?.isLoading == true {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .top) {
            Divider()
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                ForEach(store.ungroupedTabs) { tab in
                    ungroupedTabButton(tab)
                }
                ForEach(store.tabGroups) { group in
                    groupSection(group)
                }
                Button(action: { store.send(.addTab) }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .scrollIndicators(.hidden)
        .frame(minHeight: 40)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private func groupSection(_ group: TabGroup) -> some View {
        HStack(spacing: 2) {
            groupHeader(group)
            if !group.isCollapsed {
                ForEach(group.tabs) { tab in
                    groupedTabButton(tab, group: group)
                }
            }
        }
    }

    private func groupHeader(_ group: TabGroup) -> some View {
        Button {
            store.send(.toggleGroupCollapse(group.id))
        } label: {
            HStack(spacing: 4) {
                Image(systemName: group.isCollapsed ? "chevron.right" : "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
                Circle()
                    .fill(group.color.color)
                    .frame(width: 8, height: 8)
                if store.renamingGroupId == group.id {
                    TextField("Group name", text: $store.renameText)
                        .textFieldStyle(.plain)
                        .frame(width: 80)
                        .focused($renameFieldFocused)
                        .onSubmit {
                            store.send(.renameGroup(id: group.id, name: store.renameText))
                        }
                } else {
                    Text(group.label)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(group.color.color.opacity(0.15))
            .clipShape(.rect(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Rename") {
                store.send(.startRenamingGroup(group.id))
            }
            Menu("Change Color") {
                ForEach(GroupColor.allCases, id: \.self) { gc in
                    Button {
                        store.send(.changeGroupColor(id: group.id, color: gc))
                    } label: {
                        Label(gc.rawValue.capitalized, systemImage: "circle.fill")
                            .foregroundStyle(gc.color)
                    }
                }
            }
            Divider()
            Button("Ungroup All") {
                store.send(.ungroupAll(group.id))
            }
            Button("Close Group", role: .destructive) {
                store.send(.closeGroup(group.id))
            }
        }
    }

    private func ungroupedTabButton(_ tab: BrowserTab) -> some View {
        tabButtonContent(tab)
            .contextMenu {
                Button("Add to New Group") {
                    store.send(.createGroup(from: tab.id))
                }
                if !store.tabGroups.isEmpty {
                    Menu("Add to Group") {
                        ForEach(store.tabGroups) { group in
                            Button(group.label) {
                                store.send(.addTabToGroup(tabId: tab.id, groupId: group.id))
                            }
                        }
                    }
                }
                Divider()
                Button("Close Tab", role: .destructive) {
                    store.send(.closeTab(tab.id))
                }
            }
    }

    private func groupedTabButton(_ tab: BrowserTab, group: TabGroup) -> some View {
        tabButtonContent(tab, groupColor: group.color)
            .contextMenu {
                Button("Remove from Group") {
                    store.send(.removeTabFromGroup(tab.id))
                }
                Divider()
                Button("Close Tab", role: .destructive) {
                    store.send(.closeTab(tab.id))
                }
            }
    }

    private func tabButtonContent(_ tab: BrowserTab, groupColor: GroupColor? = nil) -> some View {
        let isSelected = tab.id == store.selectedId
        return Button {
            store.send(.selectTab(tab.id))
        } label: {
            HStack(spacing: 6) {
                if let gc = groupColor {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(gc.color)
                        .frame(width: 3)
                }
                Text(tab.displayTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 150)
            }
            .padding(.leading, 10)
            .padding(.trailing, 28)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear)
        .clipShape(.rect(cornerRadius: 6))
        .overlay(alignment: .trailing) {
            Button(action: { store.send(.closeTab(tab.id)) }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 6)
        }
    }

    // MARK: - Content Area

    private var contentArea: some View {
        ZStack(alignment: .topLeading) {
            ForEach(store.allTabs) { tab in
                WebView(
                    tab: tab,
                    isActive: tab.id == store.selectedId,
                    send: { store.send($0) },
                    onRegisterWebView: { view in
                        if let w = view {
                            currentWebView = w
                        }
                    }
                )
                .opacity(tab.id == store.selectedId ? 1 : 0)
                .allowsHitTesting(tab.id == store.selectedId)
                .zIndex(tab.id == store.selectedId ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
    .frame(width: 900, height: 600)
}
