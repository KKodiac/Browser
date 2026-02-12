import Foundation

struct BrowserTab: Equatable, Identifiable {
    let id: UUID
    var url: URL?
    var title: String
    var isLoading: Bool
    var canGoBack: Bool
    var canGoForward: Bool
    var suggestedURL: String
    var requestedLoad: Bool

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
