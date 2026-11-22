import Foundation

struct AutocompleteSuggestion: Identifiable, Equatable {
    enum Source: Int {
        case history, bookmark, popular
    }

    var title: String
    var url: URL
    var source: Source
    var visitCount: Int = 0
    var lastVisited: Date = .distantPast

    var id: String { SuggestionEngine.key(for: url) }
}

/// Matches URL bar input against history, bookmarks and a built-in popular-sites list.
/// Prefix matches (host/URL or title) rank above substring matches; ties break on
/// visit count, then recency.
enum SuggestionEngine {
    static let limit = 8

    static func suggestions(
        for query: String,
        history: [HistoryEntry],
        bookmarks: [Bookmark]
    ) -> [AutocompleteSuggestion] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        let urlQuery = stripPrefixes(q)

        // Merge sources, one candidate per URL (history > bookmark > popular).
        var candidates: [String: AutocompleteSuggestion] = [:]
        for entry in history {
            let key = key(for: entry.url)
            if var existing = candidates[key] {
                existing.visitCount += 1
                if entry.visitedAt > existing.lastVisited {
                    existing.lastVisited = entry.visitedAt
                    if !entry.title.isEmpty { existing.title = entry.title }
                }
                candidates[key] = existing
            } else {
                candidates[key] = AutocompleteSuggestion(
                    title: entry.title, url: entry.url, source: .history,
                    visitCount: 1, lastVisited: entry.visitedAt
                )
            }
        }
        for bookmark in bookmarks {
            let key = key(for: bookmark.url)
            if candidates[key] == nil {
                candidates[key] = AutocompleteSuggestion(title: bookmark.title, url: bookmark.url, source: .bookmark)
            } else if candidates[key]?.title.isEmpty == true {
                candidates[key]?.title = bookmark.title
            }
        }
        for site in popularSites {
            let key = key(for: site.url)
            if candidates[key] == nil {
                candidates[key] = AutocompleteSuggestion(title: site.title, url: site.url, source: .popular)
            }
        }

        let ranked: [(rank: Int, suggestion: AutocompleteSuggestion)] = candidates.compactMap { key, suggestion in
            let title = suggestion.title.lowercased()
            if key.hasPrefix(urlQuery) || title.hasPrefix(q) {
                return (0, suggestion)
            }
            if key.contains(urlQuery) || title.contains(q) {
                return (1, suggestion)
            }
            return nil
        }

        return ranked
            .sorted { lhs, rhs in
                let l = lhs.suggestion, r = rhs.suggestion
                if lhs.rank != rhs.rank { return lhs.rank < rhs.rank }
                if l.visitCount != r.visitCount { return l.visitCount > r.visitCount }
                if l.lastVisited != r.lastVisited { return l.lastVisited > r.lastVisited }
                if l.source != r.source { return l.source.rawValue < r.source.rawValue }
                return l.id.count < r.id.count
            }
            .prefix(limit)
            .map(\.suggestion)
    }

    /// Lowercased URL without scheme, leading "www." or trailing "/", used for matching and dedup.
    static func key(for url: URL) -> String {
        var s = stripPrefixes(url.absoluteString.lowercased())
        while s.hasSuffix("/") { s.removeLast() }
        return s
    }

    private static func stripPrefixes(_ s: String) -> String {
        var s = s
        for prefix in ["https://", "http://"] where s.hasPrefix(prefix) {
            s.removeFirst(prefix.count)
        }
        if s.hasPrefix("www.") { s.removeFirst(4) }
        return s
    }

    private static let popularSites: [(title: String, url: URL)] = [
        ("Google", "https://www.google.com"),
        ("YouTube", "https://www.youtube.com"),
        ("GitHub", "https://github.com"),
        ("Wikipedia", "https://www.wikipedia.org"),
        ("Reddit", "https://www.reddit.com"),
        ("Amazon", "https://www.amazon.com"),
        ("Apple", "https://www.apple.com"),
        ("Apple Developer", "https://developer.apple.com"),
        ("Stack Overflow", "https://stackoverflow.com"),
        ("X", "https://x.com"),
        ("Facebook", "https://www.facebook.com"),
        ("Instagram", "https://www.instagram.com"),
        ("LinkedIn", "https://www.linkedin.com"),
        ("Netflix", "https://www.netflix.com"),
        ("Gmail", "https://mail.google.com"),
        ("Google Maps", "https://maps.google.com"),
        ("Google Drive", "https://drive.google.com"),
        ("Hacker News", "https://news.ycombinator.com"),
        ("Medium", "https://medium.com"),
        ("Twitch", "https://www.twitch.tv"),
        ("Spotify", "https://open.spotify.com"),
        ("Dropbox", "https://www.dropbox.com"),
        ("Notion", "https://www.notion.so"),
        ("Figma", "https://www.figma.com"),
        ("Slack", "https://slack.com"),
        ("Discord", "https://discord.com"),
        ("Microsoft", "https://www.microsoft.com"),
        ("Outlook", "https://outlook.live.com"),
        ("Bing", "https://www.bing.com"),
        ("DuckDuckGo", "https://duckduckgo.com"),
        ("The New York Times", "https://www.nytimes.com"),
        ("BBC", "https://www.bbc.com"),
        ("CNN", "https://www.cnn.com"),
        ("eBay", "https://www.ebay.com"),
        ("Pinterest", "https://www.pinterest.com"),
        ("Naver", "https://www.naver.com"),
        ("ChatGPT", "https://chatgpt.com"),
        ("Claude", "https://claude.ai"),
        ("Swift.org", "https://www.swift.org"),
        ("MDN Web Docs", "https://developer.mozilla.org"),
    ].compactMap { (title: String, string: String) in
        guard let url = URL(string: string) else { return nil }
        return (title, url)
    }
}
