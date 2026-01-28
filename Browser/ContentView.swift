import SwiftUI
import WebKit

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
            toolbar
            tabBar
            contentArea
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
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            Button(action: { currentWebView?.goBack() }) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)
            .disabled(selectedTab?.canGoBack != true)

            Button(action: { currentWebView?.goForward() }) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.plain)
            .disabled(selectedTab?.canGoForward != true)

            Button(action: { currentWebView?.reload() }) {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            .disabled(selectedTab?.isLoading == true)

            TextField("Search or enter URL", text: $urlBarText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
                .onSubmit {
                    loadURL(urlBarText)
                }
                .focused($urlBarFocused)

            if selectedTab?.isLoading == true {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(tabs) { tab in
                    tabButton(tab)
                }
                Button(action: addTab) {
                    Image(systemName: "plus")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .frame(height: 36)
        .background(Color(nsColor: .controlBackgroundColor))
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
                    onLoadURL: { _ in }
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
