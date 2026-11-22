import AppKit
import Foundation

final class FaviconCache {
    static let shared = FaviconCache()

    private let cache = NSCache<NSURL, NSImage>()

    func image(for url: URL) -> NSImage? {
        cache.object(forKey: url as NSURL)
    }

    func store(_ image: NSImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }

    func fetchImage(for url: URL) async -> NSImage? {
        if let cached = image(for: url) { return cached }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = NSImage(data: data) else { return nil }
            store(image, for: url)
            return image
        } catch {
            return nil
        }
    }
}
