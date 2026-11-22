import Foundation
import Observation
import WebKit

enum DownloadState: Equatable {
    case pending
    case downloading
    case completed
    case failed
    case cancelled
}

@Observable
final class DownloadItem: Identifiable {
    let id: UUID
    let sourceURL: URL
    var filename: String
    var state: DownloadState
    var bytesReceived: Int64
    var totalBytes: Int64
    var destinationURL: URL?
    var errorMessage: String?
    var wkDownload: WKDownload?

    init(id: UUID = UUID(), sourceURL: URL, filename: String) {
        self.id = id
        self.sourceURL = sourceURL
        self.filename = filename
        self.state = .pending
        self.bytesReceived = 0
        self.totalBytes = -1
    }

    var progress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(bytesReceived) / Double(totalBytes)
    }
}

@Observable
final class DownloadManager {
    var downloads: [DownloadItem] = []

    private let downloadsDirectory: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

    // MARK: - Lifecycle

    func startDownload(sourceURL: URL, suggestedFilename: String, wkDownload: WKDownload) -> (DownloadItem, URL) {
        let item = DownloadItem(sourceURL: sourceURL, filename: suggestedFilename)
        item.state = .downloading
        item.wkDownload = wkDownload
        downloads.insert(item, at: 0)

        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent(item.id.uuidString + "-" + suggestedFilename)
        return (item, tempURL)
    }

    func updateProgress(id: UUID, bytesReceived: Int64, totalBytes: Int64) {
        guard let item = downloads.first(where: { $0.id == id }), item.state == .downloading else { return }
        item.bytesReceived = bytesReceived
        item.totalBytes = totalBytes
    }

    func completeDownload(id: UUID, tempURL: URL) {
        guard let item = downloads.first(where: { $0.id == id }) else { return }
        let destination = uniqueDestination(for: item.filename)
        do {
            try FileManager.default.moveItem(at: tempURL, to: destination)
            item.destinationURL = destination
            item.state = .completed
        } catch {
            item.errorMessage = error.localizedDescription
            item.state = .failed
        }
    }

    func failDownload(id: UUID, error: String) {
        guard let item = downloads.first(where: { $0.id == id }) else { return }
        item.errorMessage = error
        item.state = .failed
    }

    func cancelDownload(id: UUID) {
        guard let item = downloads.first(where: { $0.id == id }) else { return }
        item.wkDownload?.cancel { _ in }
        item.state = .cancelled
        item.wkDownload = nil
    }

    func clearCompleted() {
        downloads.removeAll { $0.state == .completed || $0.state == .failed || $0.state == .cancelled }
    }

    // MARK: - Computed

    var activeDownloads: [DownloadItem] {
        downloads.filter { $0.state == .pending || $0.state == .downloading }
    }

    var completedDownloads: [DownloadItem] {
        downloads.filter { $0.state == .completed || $0.state == .failed || $0.state == .cancelled }
    }

    var activeCount: Int {
        activeDownloads.count
    }

    // MARK: - Helpers

    private func uniqueDestination(for filename: String) -> URL {
        var url = downloadsDirectory.appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: url.path) else { return url }

        let name = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension
        var counter = 1
        repeat {
            let newName = ext.isEmpty ? "\(name)-\(counter)" : "\(name)-\(counter).\(ext)"
            url = downloadsDirectory.appendingPathComponent(newName)
            counter += 1
        } while FileManager.default.fileExists(atPath: url.path)
        return url
    }
}
