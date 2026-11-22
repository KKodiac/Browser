import SwiftUI

struct NewTabPageView: View {
    @Environment(BookmarkStore.self) private var bookmarkStore
    @Environment(HistoryStore.self) private var historyStore
    var accentColor: Color
    var onNavigate: (URL) -> Void
    var onFocusURLBar: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 60)
                searchField
                if !frequentSites.isEmpty {
                    siteGrid(title: "Frequently Visited", sites: frequentSites)
                }
                if !favoriteSites.isEmpty {
                    siteGrid(title: "Favorites", sites: favoriteSites)
                }
                if frequentSites.isEmpty && favoriteSites.isEmpty {
                    emptyState
                }
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
    }

    private var searchField: some View {
        Button(action: onFocusURLBar) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                Text("Search or enter URL")
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.07))
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 500)
    }

    private struct SiteItem: Identifiable {
        let id = UUID()
        let title: String
        let url: URL
    }

    private var frequentSites: [SiteItem] {
        let seen = NSMutableSet()
        var result: [SiteItem] = []
        for entry in historyStore.entries.prefix(100) {
            let host = entry.url.host ?? ""
            if seen.contains(host) { continue }
            seen.add(host)
            result.append(SiteItem(title: entry.displayTitle, url: entry.url))
            if result.count >= 8 { break }
        }
        return result
    }

    private var favoriteSites: [SiteItem] {
        bookmarkStore.bookmarks.prefix(8).map {
            SiteItem(title: $0.title, url: $0.url)
        }
    }

    private func siteGrid(title: String, sites: [SiteItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(sites) { site in
                    Button {
                        onNavigate(site.url)
                    } label: {
                        VStack(spacing: 6) {
                            Text(String((site.url.host ?? "?").prefix(1)).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(accentColor)
                                .frame(width: 48, height: 48)
                                .background(accentColor.opacity(0.15))
                                .clipShape(.rect(cornerRadius: 12, style: .continuous))
                            Text(site.title)
                                .font(.system(size: 11))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: 500)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("Welcome")
                .font(.system(size: 20, weight: .semibold))
            Text("Start browsing by typing a URL above")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }
}
