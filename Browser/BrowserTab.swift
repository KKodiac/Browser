import Foundation
import WebKit

/// Represents a single browser tab: identity, URL, title, and navigation state.
/// The web engine (WKWebView) is owned by the UI layer and updates this model via delegate callbacks.
final class BrowserTab: Identifiable, ObservableObject {
    let id: UUID
    @Published var url: URL?
    @Published var title: String
    @Published var isLoading: Bool
    @Published var canGoBack: Bool
    @Published var canGoForward: Bool
    @Published var suggestedURL: String  // For URL bar display / pending load
    /// Set when user submits URL bar; cleared when we start the load. Allows reloading same URL.
    @Published var requestedLoad: Bool

    init(
        id: UUID = UUID(),
        url: URL? = nil,
        title: String = "New Tab",
        isLoading: Bool = false,
        canGoBack: Bool = false,
        canGoForward: Bool = false,
        suggestedURL: String = "",
        requestedLoad: Bool = false
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.isLoading = isLoading
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        self.suggestedURL = suggestedURL
        self.requestedLoad = requestedLoad
    }

    var displayTitle: String {
        if !title.isEmpty && title != "New Tab" { return title }
        return url?.host ?? "New Tab"
    }

    var urlString: String {
        url?.absoluteString ?? suggestedURL
    }
}
