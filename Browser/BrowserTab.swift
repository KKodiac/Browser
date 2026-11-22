import Foundation

struct BrowserTab: Equatable, Identifiable, Codable {
    let id: UUID
    var url: URL?
    var title: String
    var isLoading: Bool
    var canGoBack: Bool
    var canGoForward: Bool
    var suggestedURL: String
    var requestedLoad: Bool
    var isPinned: Bool
    var zoomLevel: Double
    var faviconURL: URL?
    var estimatedProgress: Double

    init(
        id: UUID = UUID(),
        url: URL? = nil,
        title: String = "New Tab",
        isLoading: Bool = false,
        canGoBack: Bool = false,
        canGoForward: Bool = false,
        suggestedURL: String = "",
        requestedLoad: Bool = false,
        isPinned: Bool = false,
        zoomLevel: Double = 1.0,
        faviconURL: URL? = nil,
        estimatedProgress: Double = 0
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.isLoading = isLoading
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        self.suggestedURL = suggestedURL
        self.requestedLoad = requestedLoad
        self.isPinned = isPinned
        self.zoomLevel = zoomLevel
        self.faviconURL = faviconURL
        self.estimatedProgress = estimatedProgress
    }

    // Exclude transient properties from persistence
    enum CodingKeys: String, CodingKey {
        case id, url, title, suggestedURL, isPinned, zoomLevel, faviconURL
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        url = try c.decodeIfPresent(URL.self, forKey: .url)
        title = try c.decode(String.self, forKey: .title)
        suggestedURL = try c.decode(String.self, forKey: .suggestedURL)
        isPinned = try c.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        zoomLevel = try c.decodeIfPresent(Double.self, forKey: .zoomLevel) ?? 1.0
        faviconURL = try c.decodeIfPresent(URL.self, forKey: .faviconURL)
        isLoading = false
        canGoBack = false
        canGoForward = false
        requestedLoad = false
        estimatedProgress = 0
    }

    var displayTitle: String {
        if !title.isEmpty && title != "New Tab" { return title }
        return url?.host ?? "New Tab"
    }

    var urlString: String {
        url?.absoluteString ?? suggestedURL
    }
}
