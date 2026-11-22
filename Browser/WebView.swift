import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    var tab: BrowserTab
    var isActive: Bool
    var send: (AppFeature.Action) -> Void
    var onRegisterWebView: (WKWebView?) -> Void
    var downloadManager: DownloadManager?
    var contentBlockingEnabled: Bool = false

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Content blocker
        if contentBlockingEnabled, let ruleList = ContentBlockerManager.shared.ruleList {
            config.userContentController.add(ruleList)
        }
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
        context.coordinator.downloadManager = downloadManager
        if isActive {
            DispatchQueue.main.async {
                onRegisterWebView(webView)
            }
        }
        // Zoom
        webView.pageZoom = tab.zoomLevel
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
        Coordinator(tab: tab, send: send, onRegisterWebView: onRegisterWebView, downloadManager: downloadManager)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
        var tab: BrowserTab
        var webView: WKWebView?
        var send: (AppFeature.Action) -> Void
        var onRegisterWebView: (WKWebView?) -> Void
        var downloadManager: DownloadManager?
        var lastLoadedURL: URL?
        private var downloadItems: [WKDownload: UUID] = [:]
        private var downloadTempURLs: [UUID: URL] = [:]

        init(tab: BrowserTab, send: @escaping (AppFeature.Action) -> Void, onRegisterWebView: @escaping (WKWebView?) -> Void, downloadManager: DownloadManager?) {
            self.tab = tab
            self.send = send
            self.onRegisterWebView = onRegisterWebView
            self.downloadManager = downloadManager
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
            // Favicon extraction
            extractFavicon(from: webView)
        }

        private func extractFavicon(from webView: WKWebView) {
            let js = """
            (function() {
                var link = document.querySelector("link[rel~='icon']") || document.querySelector("link[rel='shortcut icon']");
                return link ? link.href : null;
            })()
            """
            webView.evaluateJavaScript(js) { [weak self] result, _ in
                guard let self, let urlString = result as? String, let url = URL(string: urlString) else {
                    // Fallback to /favicon.ico
                    if let pageURL = webView.url, let scheme = pageURL.scheme, let host = pageURL.host {
                        let fallback = URL(string: "\(scheme)://\(host)/favicon.ico")
                        self?.send(.updateFavicon(tabId: self?.tab.id ?? UUID(), faviconURL: fallback))
                    }
                    return
                }
                self.send(.updateFavicon(tabId: self.tab.id, faviconURL: url))
            }
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

        // MARK: - Navigation Response (Download Detection)

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if navigationResponse.canShowMIMEType {
                decisionHandler(.allow)
            } else {
                decisionHandler(.download)
            }
        }

        func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
            download.delegate = self
        }

        func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
            download.delegate = self
        }

        // MARK: - WKDownloadDelegate

        func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
            guard let manager = downloadManager else {
                completionHandler(nil)
                return
            }
            let sourceURL = download.originalRequest?.url ?? response.url ?? URL(string: "about:blank")!
            let (item, tempURL) = manager.startDownload(sourceURL: sourceURL, suggestedFilename: suggestedFilename, wkDownload: download)
            downloadItems[download] = item.id
            downloadTempURLs[item.id] = tempURL
            completionHandler(tempURL)
        }

        func download(_ download: WKDownload, didReceiveData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            guard let id = downloadItems[download] else { return }
            downloadManager?.updateProgress(id: id, bytesReceived: totalBytesWritten, totalBytes: totalBytesExpectedToWrite)
        }

        func downloadDidFinish(_ download: WKDownload) {
            guard let id = downloadItems[download], let tempURL = downloadTempURLs[id] else { return }
            downloadManager?.completeDownload(id: id, tempURL: tempURL)
            downloadItems.removeValue(forKey: download)
            downloadTempURLs.removeValue(forKey: id)
        }

        func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
            guard let id = downloadItems[download] else { return }
            downloadManager?.failDownload(id: id, error: error.localizedDescription)
            downloadItems.removeValue(forKey: download)
            downloadTempURLs.removeValue(forKey: id)
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
