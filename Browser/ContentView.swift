import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers
import WebKit

struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>
    @Environment(BookmarkStore.self) private var bookmarkStore
    @Environment(DownloadManager.self) private var downloadManager
    @Environment(HistoryStore.self) private var historyStore
    @AppStorage("contentBlockingEnabled") private var contentBlockingEnabled: Bool = true
    @State private var currentWebView: WKWebView?
    @State private var splitWebView: WKWebView?
    @State private var hoveredTabId: UUID?
    @State private var draggedTabId: UUID?
    @State private var showBookmarksSidebar = false
    @State private var showDownloadsPopover = false
    @State private var showHistoryPanel = false
    @State private var showSplitView = false
    @State private var editingBookmarkId: UUID?
    @FocusState private var urlBarFocused: Bool
    @FocusState private var renameFieldFocused: Bool

    var body: some View {
        mainLayout
            .onAppear {
                store.send(.onAppear)
                ContentBlockerManager.shared.compileRules()
            }
            .modifier(TriggerModifiers(
                store: store,
                urlBarFocused: $urlBarFocused,
                renameFieldFocused: $renameFieldFocused,
                showBookmarksSidebar: $showBookmarksSidebar,
                showDownloadsPopover: $showDownloadsPopover,
                showHistoryPanel: $showHistoryPanel,
                showSplitView: $showSplitView,
                addOrEditBookmark: addOrEditBookmark,
                performFind: { text in performFind(text) },
                recordHistory: { if let tab = store.selectedTab { recordHistory(for: tab) } }
            ))
    }

    private var mainLayout: some View {
        HStack(spacing: 0) {
            if showBookmarksSidebar {
                BookmarksSidebar(onSelectBookmark: openBookmarkURL)
                Divider()
            }
            if showHistoryPanel {
                HistoryPanel(
                    onSelectEntry: openBookmarkURL,
                    onDismiss: { showHistoryPanel = false }
                )
                Divider()
            }
            VStack(spacing: 0) {
                contentArea
                    .safeAreaInset(edge: .top, spacing: 0) { tabBar }
                    .safeAreaInset(edge: .bottom, spacing: 0) { urlBar }
                    .overlay(alignment: .topTrailing) {
                        if store.showFindBar {
                            FindBar(store: store)
                        }
                    }
            }
        }
    }

    private func performFind(_ text: String, forward: Bool = true) {
        guard let webView = currentWebView else { return }
        guard !text.isEmpty else {
            // Clear highlights
            webView.evaluateJavaScript("window.getSelection().removeAllRanges()", completionHandler: nil)
            store.send(.updateFindResults(matchCount: 0, matchIndex: 0))
            return
        }
        let js = "window.find('\(text.replacingOccurrences(of: "'", with: "\\'"))', false, \(!forward), true)"
        webView.evaluateJavaScript(js) { result, _ in
            let found = result as? Bool ?? false
            // Simple match tracking - WebKit's window.find doesn't give total count easily
            if found {
                if store.findMatchCount == 0 {
                    store.send(.updateFindResults(matchCount: 1, matchIndex: 0))
                }
            } else {
                store.send(.updateFindResults(matchCount: 0, matchIndex: 0))
            }
        }
    }

    private func openBookmarkURL(_ url: URL) {
        store.send(.binding(.set(\.urlBarText, url.absoluteString)))
        store.send(.urlBarSubmitted)
    }

    private func recordHistory(for tab: BrowserTab) {
        guard let url = tab.url, url.scheme == "https" || url.scheme == "http" else { return }
        historyStore.addEntry(url: url, title: tab.title)
    }

    private func addOrEditBookmark() {
        guard let tab = store.selectedTab, let url = tab.url else { return }
        if bookmarkStore.isBookmarked(url: url) {
            showBookmarksSidebar = true
            editingBookmarkId = bookmarkStore.bookmark(for: url)?.id
        } else {
            let title = tab.title.isEmpty || tab.title == "New Tab"
                ? (url.host ?? url.absoluteString)
                : tab.title
            bookmarkStore.addBookmark(title: title, url: url)
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

            Button(action: addOrEditBookmark) {
                Image(systemName: bookmarkStore.isBookmarked(url: store.selectedTab?.url) ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(bookmarkStore.isBookmarked(url: store.selectedTab?.url) ? store.accentColor.color : .secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: { showDownloadsPopover.toggle() }) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
                    .overlay(alignment: .topTrailing) {
                        if downloadManager.activeCount > 0 {
                            Text("\(downloadManager.activeCount)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(store.accentColor.color)
                                .clipShape(Capsule())
                                .offset(x: 4, y: -4)
                        }
                    }
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showDownloadsPopover) {
                DownloadsPopover()
            }

            Button(action: { showHistoryPanel.toggle() }) {
                Image(systemName: "clock")
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: { showBookmarksSidebar.toggle() }) {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Zoom indicator
            if let zoom = store.selectedTab?.zoomLevel, abs(zoom - 1.0) > 0.01 {
                Button(action: { store.send(.resetZoom) }) {
                    Text("\(Int(zoom * 100))%")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.06))
                        .clipShape(.rect(cornerRadius: 4))
                }
                .buttonStyle(.plain)
                .help("Reset Zoom")
            }

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

    private var pinnedTabs: [BrowserTab] {
        store.allTabs.filter(\.isPinned)
    }

    private var unpinnedUngroupedTabs: IdentifiedArrayOf<BrowserTab> {
        store.ungroupedTabs.filter { !$0.isPinned }
    }

    private var tabBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                // Pinned tabs first
                ForEach(pinnedTabs) { tab in
                    pinnedTabButton(tab)
                }
                if !pinnedTabs.isEmpty && (!unpinnedUngroupedTabs.isEmpty || !store.tabGroups.isEmpty) {
                    Divider().frame(height: 20).padding(.horizontal, 2)
                }
                ForEach(unpinnedUngroupedTabs) { tab in
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

    private func pinnedTabButton(_ tab: BrowserTab) -> some View {
        Button {
            store.send(.selectTab(tab.id))
        } label: {
            faviconView(for: tab)
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
        .background(tab.id == store.selectedId ? store.accentColor.color.opacity(0.15) : Color.clear)
        .clipShape(.rect(cornerRadius: 8, style: .continuous))
        .overlay(
            Group {
                if tab.id == store.selectedId {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(store.accentColor.color.opacity(0.25), lineWidth: 0.5)
                }
            }
        )
        .help(tab.displayTitle)
        .contextMenu {
            Button("Unpin Tab") { store.send(.togglePinTab(tab.id)) }
            Divider()
            Button("Close Tab", role: .destructive) { store.send(.closeTab(tab.id)) }
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
                Button(tab.isPinned ? "Unpin Tab" : "Pin Tab") {
                    store.send(.togglePinTab(tab.id))
                }
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

    @ViewBuilder
    private func faviconView(for tab: BrowserTab) -> some View {
        if let faviconURL = tab.faviconURL {
            AsyncImage(url: faviconURL) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "globe")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 14, height: 14)
        } else {
            Image(systemName: "globe")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 14, height: 14)
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
                faviconView(for: tab)
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
        HStack(spacing: 0) {
            mainWebContent
            if showSplitView, let splitId = store.splitTabId, let splitTab = store.allTabs[id: splitId] {
                Divider()
                ZStack {
                    WebView(
                        tab: splitTab,
                        isActive: true,
                        send: { store.send($0) },
                        onRegisterWebView: { view in
                            if let w = view { splitWebView = w }
                        },
                        downloadManager: downloadManager,
                        contentBlockingEnabled: contentBlockingEnabled
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var mainWebContent: some View {
        ZStack(alignment: .topLeading) {
            // New tab page when no URL loaded
            if store.selectedTab?.url == nil {
                NewTabPageView(
                    accentColor: store.accentColor.color,
                    onNavigate: openBookmarkURL,
                    onFocusURLBar: { urlBarFocused = true }
                )
            }
            ForEach(store.allTabs) { tab in
                WebView(
                    tab: tab,
                    isActive: tab.id == store.selectedId,
                    send: { store.send($0) },
                    onRegisterWebView: { view in
                        if let w = view {
                            currentWebView = w
                        }
                    },
                    downloadManager: downloadManager,
                    contentBlockingEnabled: contentBlockingEnabled
                )
                .opacity(tab.id == store.selectedId && tab.url != nil ? 1 : 0)
                .allowsHitTesting(tab.id == store.selectedId)
                .zIndex(tab.id == store.selectedId ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top) {
            LoadingProgressBar(
                progress: store.selectedTab?.estimatedProgress ?? 0,
                isLoading: store.selectedTab?.isLoading == true,
                color: store.accentColor.color
            )
        }
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

// MARK: - Loading Progress Bar

private struct LoadingProgressBar: View {
    var progress: Double
    var isLoading: Bool
    var color: Color
    @State private var shownProgress: Double = 0

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(color)
                .frame(width: geo.size.width * shownProgress, height: 2)
        }
        .frame(height: 2)
        .opacity(isLoading ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: isLoading)
        .allowsHitTesting(false)
        .onAppear { shownProgress = progress }
        .onChange(of: progress) { oldValue, newValue in
            // Grow smoothly; jump back instantly when a new load (or tab) starts lower
            if newValue < oldValue {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) { shownProgress = newValue }
            } else {
                withAnimation(.easeOut(duration: 0.2)) { shownProgress = newValue }
            }
        }
    }
}

// MARK: - Trigger Modifiers (extracted to help type-checker)

private struct TriggerModifiers: ViewModifier {
    @Bindable var store: StoreOf<AppFeature>
    var urlBarFocused: FocusState<Bool>.Binding
    var renameFieldFocused: FocusState<Bool>.Binding
    @Binding var showBookmarksSidebar: Bool
    @Binding var showDownloadsPopover: Bool
    @Binding var showHistoryPanel: Bool
    @Binding var showSplitView: Bool
    var addOrEditBookmark: () -> Void
    var performFind: (String) -> Void
    var recordHistory: () -> Void

    func body(content: Content) -> some View {
        content
            .modifier(TriggerModifiersA(
                store: store,
                urlBarFocused: urlBarFocused,
                renameFieldFocused: renameFieldFocused,
                showBookmarksSidebar: $showBookmarksSidebar,
                showDownloadsPopover: $showDownloadsPopover,
                addOrEditBookmark: addOrEditBookmark
            ))
            .modifier(TriggerModifiersB(
                store: store,
                showHistoryPanel: $showHistoryPanel,
                showSplitView: $showSplitView,
                performFind: performFind,
                recordHistory: recordHistory
            ))
    }
}

private struct TriggerModifiersA: ViewModifier {
    @Bindable var store: StoreOf<AppFeature>
    var urlBarFocused: FocusState<Bool>.Binding
    var renameFieldFocused: FocusState<Bool>.Binding
    @Binding var showBookmarksSidebar: Bool
    @Binding var showDownloadsPopover: Bool
    var addOrEditBookmark: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: store.focusURLBarTrigger) { _, _ in
                urlBarFocused.wrappedValue = true
            }
            .onChange(of: store.focusRenameFieldTrigger) { _, _ in
                renameFieldFocused.wrappedValue = true
            }
            .onChange(of: store.addBookmarkTrigger) { _, _ in
                addOrEditBookmark()
            }
            .onChange(of: store.toggleBookmarksSidebarTrigger) { _, _ in
                showBookmarksSidebar.toggle()
            }
            .onChange(of: store.toggleDownloadsPopoverTrigger) { _, _ in
                showDownloadsPopover.toggle()
            }
    }
}

private struct TriggerModifiersB: ViewModifier {
    @Bindable var store: StoreOf<AppFeature>
    @Binding var showHistoryPanel: Bool
    @Binding var showSplitView: Bool
    var performFind: (String) -> Void
    var recordHistory: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: store.toggleHistoryPanelTrigger) { _, _ in
                showHistoryPanel.toggle()
            }
            .onChange(of: store.toggleSplitViewTrigger) { _, _ in
                showSplitView = store.splitTabId != nil
            }
            .onChange(of: store.findText) { _, newValue in
                performFind(newValue)
            }
            .onChange(of: store.selectedTab?.url) { _, _ in
                recordHistory()
            }
    }
}

#Preview {
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
    .environment(BookmarkStore())
    .environment(DownloadManager())
    .environment(HistoryStore())
    .frame(width: 900, height: 600)
}
