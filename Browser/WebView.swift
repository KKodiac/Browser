import SwiftUI
import WebKit

/// Wraps WKWebView for use in SwiftUI. Updates the provided BrowserTab with URL, title, and loading state.
/// When this view is the active tab, it registers its WKWebView for toolbar actions (back, forward, reload).
struct WebView: NSViewRepresentable {
    @ObservedObject var tab: BrowserTab
    var isActive: Bool
    var onRegisterWebView: (WKWebView?) -> Void
    var onLoadURL: (URL) -> Void

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        context.coordinator.webView = webView
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.tab = tab
        context.coordinator.onRegisterWebView = onRegisterWebView
        if isActive {
            // Defer to avoid "Modifying state during view update" — callback sets ContentView's @State
            DispatchQueue.main.async {
                onRegisterWebView(webView)
            }
        }
        // Load only when user requested a new URL (or same URL via requestedLoad) that we haven't already started loading.
        // Without this, repeated updateNSView calls would start multiple loads and cancel the previous one (NSURLErrorCancelled -999).
        guard let url = tab.url else { return }
        let shouldLoad = url != context.coordinator.lastLoadedURL || tab.requestedLoad
        if !shouldLoad { return }
        context.coordinator.lastLoadedURL = url
        DispatchQueue.main.async { [weak tab] in tab?.requestedLoad = false }
        webView.load(URLRequest(url: url))
    }

    static func dismantleNSView(_ webView: WKWebView, coordinator: Coordinator) {
        coordinator.onRegisterWebView(nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(tab: tab, onRegisterWebView: onRegisterWebView)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var tab: BrowserTab
        var webView: WKWebView?
        var onRegisterWebView: (WKWebView?) -> Void
        /// URL we last started loading (or that finished). Prevents duplicate load() calls that cause NSURLErrorCancelled (-999).
        var lastLoadedURL: URL?

        init(tab: BrowserTab, onRegisterWebView: @escaping (WKWebView?) -> Void) {
            self.tab = tab
            self.onRegisterWebView = onRegisterWebView
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            tab.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            tab.isLoading = false
            tab.url = webView.url
            lastLoadedURL = webView.url
            tab.title = webView.title ?? "New Tab"
            tab.canGoBack = webView.canGoBack
            tab.canGoForward = webView.canGoForward
            tab.suggestedURL = webView.url?.absoluteString ?? ""
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            tab.isLoading = false
            tab.canGoBack = webView.canGoBack
            tab.canGoForward = webView.canGoForward
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            tab.isLoading = false
            // .cancelled (-999) = load superseded by another. Don't treat as real failure.
            if (error as NSError).code == URLError.Code.cancelled.rawValue { return }
            lastLoadedURL = nil
        }
    }
}

