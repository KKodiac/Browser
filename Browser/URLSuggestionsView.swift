import Observation
import SwiftUI

/// Dropdown state for the URL bar: debounced suggestions and the keyboard selection.
@MainActor
@Observable
final class URLSuggestionsModel {
    private(set) var suggestions: [AutocompleteSuggestion] = []
    private(set) var selectedIndex: Int?
    @ObservationIgnored private var task: Task<Void, Never>?

    var isVisible: Bool { !suggestions.isEmpty }

    var selected: AutocompleteSuggestion? {
        guard let selectedIndex, suggestions.indices.contains(selectedIndex) else { return nil }
        return suggestions[selectedIndex]
    }

    /// Recomputes suggestions 150ms after the last call.
    func update(query: String, history: [HistoryEntry], bookmarks: [Bookmark]) {
        task?.cancel()
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            dismiss()
            return
        }
        task = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled, let self else { return }
            self.suggestions = SuggestionEngine.suggestions(for: query, history: history, bookmarks: bookmarks)
            self.selectedIndex = nil
        }
    }

    /// Moves the selection down (+1) or up (-1). Moving up from the first row returns to the text field.
    func moveSelection(by step: Int) {
        guard isVisible else { return }
        if let selectedIndex {
            let next = selectedIndex + step
            if next < 0 {
                self.selectedIndex = nil
            } else {
                self.selectedIndex = min(next, suggestions.count - 1)
            }
        } else if step > 0 {
            selectedIndex = 0
        }
    }

    func dismiss() {
        task?.cancel()
        task = nil
        suggestions = []
        selectedIndex = nil
    }
}

struct URLSuggestionsView: View {
    var model: URLSuggestionsModel
    var accentColor: Color
    var onSelect: (URL) -> Void

    var body: some View {
        VStack(spacing: 2) {
            ForEach(Array(model.suggestions.enumerated()), id: \.element.id) { index, suggestion in
                Button(action: { onSelect(suggestion.url) }) {
                    row(suggestion, isSelected: index == model.selectedIndex)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
    }

    private func row(_ suggestion: AutocompleteSuggestion, isSelected: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon(for: suggestion.source))
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 16)
            Text(suggestion.title.isEmpty ? (suggestion.url.host ?? suggestion.url.absoluteString) : suggestion.title)
                .font(.system(size: 13))
                .lineLimit(1)
            Text(suggestion.url.absoluteString)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(isSelected ? accentColor.opacity(0.30) : Color.clear)
        .clipShape(.rect(cornerRadius: 6, style: .continuous))
        .contentShape(Rectangle())
    }

    private func icon(for source: AutocompleteSuggestion.Source) -> String {
        switch source {
        case .history: return "clock"
        case .bookmark: return "bookmark"
        case .popular: return "globe"
        }
    }
}
