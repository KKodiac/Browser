import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers
import WebKit

struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>
    @State private var currentWebView: WKWebView?
    @State private var hoveredTabId: UUID?
    @State private var draggedTabId: UUID?
    @FocusState private var urlBarFocused: Bool
    @FocusState private var renameFieldFocused: Bool

    var body: some View {
        contentArea
            .safeAreaInset(edge: .top, spacing: 0) { tabBar }
            .safeAreaInset(edge: .bottom, spacing: 0) { urlBar }
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
            HStack(spacing: 2) {
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
            .padding(4)
            .background(Color.white.opacity(0.06))
            .clipShape(.rect(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.5)
            )

            TextField("Search or enter URL", text: $store.urlBarText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.07))
                .clipShape(.rect(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    (urlBarFocused ? store.accentColor.color : Color.white)
                                        .opacity(urlBarFocused ? 0.40 : 0.15),
                                    (urlBarFocused ? store.accentColor.color : Color.white)
                                        .opacity(urlBarFocused ? 0.15 : 0.05),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: urlBarFocused ? 1 : 0.5
                        )
                )
                .onSubmit {
                    store.send(.urlBarSubmitted)
                }
                .focused($urlBarFocused)

            Menu {
                ForEach(AccentColor.allCases, id: \.self) { ac in
                    Button {
                        store.send(.setAccentColor(ac))
                    } label: {
                        Label(ac.rawValue.capitalized, systemImage: store.accentColor == ac ? "circle.inset.filled" : "circle.fill")
                    }
                }
            } label: {
                Circle()
                    .fill(store.accentColor.color)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5)
                    )
                    .shadow(color: store.accentColor.color.opacity(0.5), radius: 4)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()

            if store.selectedTab?.isLoading == true {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 0.5)
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(store.ungroupedTabs) { tab in
                    ungroupedTabButton(tab)
                }
                ForEach(store.tabGroups) { group in
                    groupSection(group)
                }
                Button(action: { store.send(.addTab) }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(store.accentColor.color)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(store.accentColor.color.opacity(0.08))
                .clipShape(.rect(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(store.accentColor.color.opacity(0.15), lineWidth: 0.5)
                )
                .onDrop(of: [.plainText], isTargeted: nil) { providers in
                    handleDrop(providers: providers, beforeTab: nil)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .frame(minHeight: 44)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 0.5)
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
                    .foregroundStyle(group.color.color)
                Circle()
                    .fill(group.color.color)
                    .frame(width: 8, height: 8)
                    .shadow(color: group.color.color.opacity(0.5), radius: 4)
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
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(group.color.color)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(group.color.color.opacity(0.10))
            .clipShape(.rect(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(group.color.color.opacity(0.20), lineWidth: 0.5)
            )
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
            .onDrag {
                draggedTabId = tab.id
                return NSItemProvider(object: tab.id.uuidString as NSString)
            }
            .onDrop(of: [.plainText], isTargeted: nil) { providers in
                handleDrop(providers: providers, beforeTab: tab.id)
            }
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
            .onDrag {
                draggedTabId = tab.id
                return NSItemProvider(object: tab.id.uuidString as NSString)
            }
            .onDrop(of: [.plainText], isTargeted: nil) { providers in
                handleDrop(providers: providers, beforeTab: tab.id)
            }
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
        let isHovered = tab.id == hoveredTabId
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
                if isSelected {
                    Spacer(minLength: 0)
                    Button(action: { store.send(.closeTab(tab.id)) }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .semibold))
                            .frame(width: 18, height: 18)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, isSelected ? 6 : 10)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .background(
            Group {
                if isSelected {
                    store.accentColor.color.opacity(0.15)
                } else if isHovered {
                    Color.white.opacity(0.06)
                } else {
                    Color.clear
                }
            }
        )
        .clipShape(.rect(cornerRadius: 10, style: .continuous))
        .overlay(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    store.accentColor.color.opacity(0.30),
                                    store.accentColor.color.opacity(0.08),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                }
            }
        )
        .shadow(color: isSelected ? Color.black.opacity(0.15) : .clear, radius: 8, y: 2)
        .shadow(color: isSelected ? Color.black.opacity(0.05) : .clear, radius: 2, y: 1)
        .opacity(draggedTabId == tab.id ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .onHover { hovering in
            hoveredTabId = hovering ? tab.id : nil
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

    // MARK: - Drag & Drop

    private func handleDrop(providers: [NSItemProvider], beforeTab: UUID?) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadObject(ofClass: NSString.self) { string, _ in
            if let uuidString = string as? String, let draggedId = UUID(uuidString: uuidString) {
                DispatchQueue.main.async {
                    store.send(.moveTab(id: draggedId, beforeTab: beforeTab))
                    draggedTabId = nil
                }
            }
        }
        return true
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
