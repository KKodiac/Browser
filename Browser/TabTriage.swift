import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// A group the triage proposes (or the user accepted): a name, a color and its tabs.
struct TabTriageGroup: Equatable, Identifiable {
    let id = UUID()
    var name: String
    var color: GroupColor
    var tabIds: [UUID]
}

/// What "Organize Tabs…" applies: new groups to create and tabs to close.
struct TabTriagePlan: Equatable {
    var groups: [TabTriageGroup]
    var closeTabIds: [UUID]
}

/// Tab info sent to the model: just the index used in the prompt, the title and the host.
struct TabTriageInput: Sendable {
    let index: Int
    let title: String
    let host: String
}

enum TabTriage {
    /// At most this many tabs are sent to the model, to stay inside its context window.
    static let maxModelTabs = 60
    /// Tabs not selected for this long are proposed as stale.
    static let staleInterval: TimeInterval = 3 * 24 * 60 * 60

    /// Unpinned tabs with the same URL (ignoring the fragment and a trailing slash) as another tab.
    /// The most recently active copy of each URL (or the selected tab) is kept; the others are returned.
    static func duplicateTabIds(in tabs: [BrowserTab], selectedId: UUID?) -> [UUID] {
        var byURL: [String: [BrowserTab]] = [:]
        for tab in tabs {
            guard let key = normalizedURL(tab.url) else { continue }
            byURL[key, default: []].append(tab)
        }
        var result: [UUID] = []
        for tab in tabs {
            guard !tab.isPinned, tab.id != selectedId,
                  let key = normalizedURL(tab.url), let copies = byURL[key], copies.count > 1 else { continue }
            let keeper = copies.first { $0.id == selectedId }
                ?? copies.first { $0.isPinned }
                ?? copies.max { $0.lastActiveAt < $1.lastActiveAt }!
            if keeper.id != tab.id { result.append(tab.id) }
        }
        return result
    }

    /// Unpinned, unselected tabs that haven't been selected for `staleInterval`.
    static func staleTabIds(in tabs: [BrowserTab], selectedId: UUID?, now: Date = Date()) -> [UUID] {
        tabs.filter { !$0.isPinned && $0.id != selectedId && now.timeIntervalSince($0.lastActiveAt) >= staleInterval }
            .map(\.id)
    }

    private static func normalizedURL(_ url: URL?) -> String? {
        guard let url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        components.fragment = nil
        if components.path.hasSuffix("/") { components.path.removeLast() }
        return components.string?.lowercased()
    }
}

#if canImport(FoundationModels)
@available(macOS 26.0, *)
@Generable
struct TriageModelOutput {
    @Guide(description: "Groups of related tabs. Only group tabs that clearly share a topic, site or task.", .maximumCount(8))
    var groups: [TriageModelGroup]
}

@available(macOS 26.0, *)
@Generable
struct TriageModelGroup {
    @Guide(description: "A short group name of one to three words, e.g. 'Shopping' or 'Swift Docs'")
    var name: String
    @Guide(description: "A color for the group", .anyOf(GroupColor.allCases.map(\.rawValue)))
    var color: String
    @Guide(description: "The numbers of the tabs in this group, as listed in the prompt. At least two tabs.")
    var tabNumbers: [Int]
}

@available(macOS 26.0, *)
extension TabTriage {
    /// Nil when the on-device model can be used; otherwise a message explaining why not.
    static var unavailableMessage: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Apple Intelligence is turned off. Turn it on in System Settings › Apple Intelligence & Siri to get group suggestions."
        case .unavailable(.deviceNotEligible):
            return "This Mac doesn't support Apple Intelligence, so group suggestions aren't available."
        case .unavailable(.modelNotReady):
            return "The Apple Intelligence model is still downloading or getting ready. Try again later."
        case .unavailable:
            return "The on-device model isn't available right now."
        }
    }

    /// Asks the on-device model to group the tabs. Indices in the result refer to `TabTriageInput.index`.
    /// Not main-actor isolated, so the generation runs off the main thread.
    static func suggestGroups(for tabs: [TabTriageInput]) async throws -> [(name: String, color: GroupColor, indices: [Int])] {
        let session = LanguageModelSession(instructions: """
            You organize web browser tabs into groups. You get a numbered list of tabs, each with its \
            page title and website. Put tabs that share a topic, project or website into the same group. \
            Each tab goes in at most one group. Leave out tabs that don't fit any group. \
            Give each group a short name and a color.
            """)
        let list = tabs.map { "\($0.index). \($0.title) — \($0.host)" }.joined(separator: "\n")
        let response = try await session.respond(
            to: "Group these tabs:\n\(list)",
            generating: TriageModelOutput.self
        )
        let valid = Set(tabs.map(\.index))
        var used = Set<Int>()
        var result: [(name: String, color: GroupColor, indices: [Int])] = []
        for group in response.content.groups {
            // Drop unknown or repeated indices the model may produce.
            let indices = group.tabNumbers.filter { valid.contains($0) && used.insert($0).inserted }
            let name = group.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard indices.count >= 2, !name.isEmpty else { continue }
            result.append((name, GroupColor(rawValue: group.color) ?? .blue, indices))
        }
        return result
    }

    static func message(for error: Error) -> String {
        guard let error = error as? LanguageModelSession.GenerationError else {
            return "Couldn't get suggestions: \(error.localizedDescription)"
        }
        switch error {
        case .exceededContextWindowSize:
            return "There's too much tab text for the on-device model. Close a few tabs and try again."
        case .guardrailViolation:
            return "The on-device model declined to process these tabs."
        case .unsupportedLanguageOrLocale:
            return "The on-device model doesn't support the language of these tabs."
        case .assetsUnavailable:
            return "The Apple Intelligence model isn't ready yet. Try again later."
        default:
            return "Couldn't get suggestions: \(error.localizedDescription)"
        }
    }
}
#endif
