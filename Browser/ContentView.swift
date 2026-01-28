import SwiftUI
import WebKit

extension Notification.Name {
    static let focusURLBar = Notification.Name("FocusURLBar")
}

struct ContentView: View {
    @State private var tabs: [BrowserTab] = [BrowserTab()]
    @State private var selectedTabId: UUID?
    @State private var currentWebView: WKWebView?
    @State private var urlBarText: String = ""
    @FocusState private var urlBarFocused: Bool

    private var selectedTab: BrowserTab? {
        tabs.first { $0.id == selectedTabId } ?? tabs.first
    }

    private var selectedId: UUID {
        get { selectedTabId ?? tabs.first!.id }
        set { selectedTabId = newValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            contentArea
            urlBar
        }
        .onAppear {
            if selectedTabId == nil, let first = tabs.first {
                selectedTabId = first.id
                urlBarText = first.suggestedURL
            }
        }
        .onChange(of: selectedTabId) { _, newId in
            if let id = newId, let t = tabs.first(where: { $0.id == id }) {
                DispatchQueue.main.async {
                    urlBarText = t.urlString
                    currentWebView = nil
                }
            }
        }
        .onChange(of: selectedTab?.urlString) { _, _ in
            if let t = selectedTab {
                DispatchQueue.main.async {
                    urlBarText = t.urlString
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusURLBar)) { _ in
            urlBarFocused = true
        }
    }

    /// URL / search bar at the bottom, below the web content.
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
                .disabled(selectedTab?.canGoBack != true)
                .opacity(selectedTab?.canGoBack == true ? 1 : 0.4)

                Button(action: { currentWebView?.goForward() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(selectedTab?.canGoForward != true)
                .opacity(selectedTab?.canGoForward == true ? 1 : 0.4)

                Button(action: { currentWebView?.reload() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(selectedTab?.isLoading == true)
            }

            TextField("Search or enter URL", text: $urlBarText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(nsColor: .separatorColor).opacity(0.6), lineWidth: 1)
                )
                .onSubmit {
                    loadURL(urlBarText)
                }
                .focused($urlBarFocused)

            if selectedTab?.isLoading == true {
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

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(tabs) { tab in
                    tabButton(tab)
                }
                Button(action: addTab) {
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
        .frame(height: 40)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private func tabButton(_ tab: BrowserTab) -> some View {
        let isSelected = tab.id == selectedId
        return HStack(spacing: 6) {
            Text(tab.displayTitle)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 150)
            Button(action: { closeTab(tab) }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isSelected ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear)
        .cornerRadius(6)
        .onTapGesture {
            selectedTabId = tab.id
        }
    }

    private var contentArea: some View {
        ZStack(alignment: .topLeading) {
            ForEach(tabs) { tab in
                WebView(
                    tab: tab,
                    isActive: tab.id == selectedId,
                    onRegisterWebView: { view in
                        if let w = view {
                            currentWebView = w
                        }
                    },
                    onLoadURL: { url in
                        DispatchQueue.main.async {
                            if tab.id == selectedId {
                                urlBarText = url.absoluteString
                            }
                        }
                    }
                )
                .opacity(tab.id == selectedId ? 1 : 0)
                .allowsHitTesting(tab.id == selectedId)
                .zIndex(tab.id == selectedId ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func addTab() {
        let tab = BrowserTab()
        tabs.append(tab)
        selectedTabId = tab.id
        urlBarText = ""
    }

    private func closeTab(_ tab: BrowserTab) {
        tabs.removeAll { $0.id == tab.id }
        if selectedTabId == tab.id {
            selectedTabId = tabs.first?.id
            if let t = tabs.first {
                urlBarText = t.urlString
            }
        }
        if tabs.isEmpty {
            let newTab = BrowserTab()
            tabs.append(newTab)
            selectedTabId = newTab.id
            urlBarText = ""
        }
    }

    private func loadURL(_ input: String) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

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

        guard let u = url else { return }
        selectedTab?.url = u
        selectedTab?.suggestedURL = u.absoluteString
        selectedTab?.requestedLoad = true
        urlBarText = u.absoluteString
    }
}

#Preview {
    ContentView()
        .frame(width: 900, height: 600)
}
