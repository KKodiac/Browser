import ComposableArchitecture
import SwiftUI

struct FindBar: View {
    @Bindable var store: StoreOf<AppFeature>
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            TextField("Find in page", text: $store.findText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .focused($isFocused)
                .onSubmit { store.send(.findNext) }

            if !store.findText.isEmpty {
                Text(matchCountText)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Button(action: { store.send(.findPrevious) }) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 11, weight: .medium))
            }
            .buttonStyle(.plain)
            .disabled(store.findMatchCount == 0)

            Button(action: { store.send(.findNext) }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .medium))
            }
            .buttonStyle(.plain)
            .disabled(store.findMatchCount == 0)

            Button(action: { store.send(.dismissFindBar) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .medium))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
        .padding(8)
        .onAppear { isFocused = true }
    }

    private var matchCountText: String {
        if store.findMatchCount == 0 { return "No matches" }
        return "\(store.findMatchIndex + 1) of \(store.findMatchCount)"
    }
}
