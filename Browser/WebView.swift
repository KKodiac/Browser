import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    var tab: BrowserTab
    var isActive: Bool
    var send: (AppFeature.Action) -> Void
    var onRegisterWebView: (WKWebView?) -> Void

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        context.coordinator.webView = webView
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.tab = tab
        context.coordinator.send = send
        context.coordinator.onRegisterWebView = onRegisterWebView
        if isActive {
            DispatchQueue.main.async {
                onRegisterWebView(webView)
            }
        }
        guard let url = tab.url else { return }
        let shouldLoad = url != context.coordinator.lastLoadedURL || tab.requestedLoad
        if !shouldLoad { return }
        context.coordinator.lastLoadedURL = url
        if tab.requestedLoad {
            DispatchQueue.main.async { [send, tab] in
                send(.webViewLoadRequestConsumed(tabId: tab.id))
            }
        }
        webView.load(URLRequest(url: url))
    }

    static func dismantleNSView(_ webView: WKWebView, coordinator: Coordinator) {
        coordinator.onRegisterWebView(nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(tab: tab, send: send, onRegisterWebView: onRegisterWebView)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var tab: BrowserTab
        var webView: WKWebView?
        var send: (AppFeature.Action) -> Void
        var onRegisterWebView: (WKWebView?) -> Void
        var lastLoadedURL: URL?

        init(tab: BrowserTab, send: @escaping (AppFeature.Action) -> Void, onRegisterWebView: @escaping (WKWebView?) -> Void) {
            self.tab = tab
            self.send = send
            self.onRegisterWebView = onRegisterWebView
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            send(.webViewNavigationStarted(tabId: tab.id))
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            lastLoadedURL = webView.url
            send(.webViewNavigationFinished(
                tabId: tab.id,
                url: webView.url,
                title: webView.title ?? "New Tab",
                canGoBack: webView.canGoBack,
                canGoForward: webView.canGoForward
            ))
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            send(.webViewNavigationFailed(
                tabId: tab.id,
                canGoBack: webView.canGoBack,
                canGoForward: webView.canGoForward
            ))
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            if (error as NSError).code == URLError.Code.cancelled.rawValue { return }
            lastLoadedURL = nil
            send(.webViewProvisionalNavigationFailed(tabId: tab.id))
        }

        // MARK: - WKUIDelegate

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = NSAlert()
            alert.messageText = message
            alert.addButton(withTitle: "OK")
            alert.runModal()
            completionHandler()
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = NSAlert()
            alert.messageText = message
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            completionHandler(alert.runModal() == .alertFirstButtonReturn)
        }

        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            let alert = NSAlert()
            alert.messageText = prompt
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
            textField.stringValue = defaultText ?? ""
            alert.accessoryView = textField
            completionHandler(alert.runModal() == .alertFirstButtonReturn ? textField.stringValue : nil)
        }
    }
}
