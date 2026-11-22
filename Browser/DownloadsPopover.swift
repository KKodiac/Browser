import AppKit
import SwiftUI

struct DownloadsPopover: View {
    @Environment(DownloadManager.self) private var manager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            if manager.downloads.isEmpty {
                emptyState
            } else {
                downloadsList
            }
        }
        .frame(width: 300)
        .frame(minHeight: 100, maxHeight: 400)
    }

    private var header: some View {
        HStack {
            Text("Downloads")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            if !manager.completedDownloads.isEmpty {
                Button("Clear") {
                    manager.clearCompleted()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var emptyState: some View {
        Text("No downloads")
            .font(.system(size: 12))
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, minHeight: 60)
    }

    private var downloadsList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(manager.activeDownloads) { item in
                    activeRow(item)
                }
                ForEach(manager.completedDownloads) { item in
                    completedRow(item)
                }
            }
            .padding(8)
        }
    }

    private func activeRow(_ item: DownloadItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.filename)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button(action: { manager.cancelDownload(id: item.id) }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            if item.totalBytes > 0 {
                ProgressView(value: item.progress)
                    .progressViewStyle(.linear)
                Text(progressText(item))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
                    .progressViewStyle(.linear)
                Text(formatBytes(item.bytesReceived))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.03))
        .clipShape(.rect(cornerRadius: 6))
    }

    private func completedRow(_ item: DownloadItem) -> some View {
        Button {
            if let url = item.destinationURL {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        } label: {
            HStack {
                Image(systemName: stateIcon(item.state))
                    .font(.system(size: 11))
                    .foregroundStyle(stateColor(item.state))
                Text(item.filename)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                if item.state == .completed {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .clipShape(.rect(cornerRadius: 6))
    }

    private func progressText(_ item: DownloadItem) -> String {
        "\(formatBytes(item.bytesReceived)) / \(formatBytes(item.totalBytes))"
    }

    private func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    private func stateIcon(_ state: DownloadState) -> String {
        switch state {
        case .completed: "checkmark.circle.fill"
        case .failed: "exclamationmark.circle.fill"
        case .cancelled: "minus.circle.fill"
        default: "circle"
        }
    }

    private func stateColor(_ state: DownloadState) -> Color {
        switch state {
        case .completed: .green
        case .failed: .red
        case .cancelled: .secondary
        default: .secondary
        }
    }
}
