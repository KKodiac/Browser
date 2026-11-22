import Foundation
import FoundationModels
import Observation
import WebKit

/// One entry in an "Ask this page" transcript.
struct AskPageMessage: Identifiable, Equatable {
    enum Role { case user, assistant, notice }

    let id = UUID()
    var role: Role
    var text: String
    /// Small caption under an answer, e.g. that the page text was trimmed.
    var note: String?
    var isError = false
}

/// Readable text of a page, read with JavaScript from its web view.
struct AskPageContent {
    var title: String
    var url: String
    var text: String
    var selection: String
    /// Length of the page's whole (whitespace-collapsed) text, before any trimming.
    var totalLength: Int

    /// Collapses whitespace and caps the text so huge pages don't cross the bridge in full.
    private static let script = """
    (function() {
      var clean = function(s) { return (s || '').replace(/[ \\t\\u00a0]+/g, ' ').replace(/\\s*\\n\\s*(\\n\\s*)+/g, '\\n\\n').trim(); };
      var body = clean(document.body ? document.body.innerText : '');
      var sel = clean(window.getSelection ? String(window.getSelection()) : '');
      return { title: document.title || '', url: location.href, text: body.slice(0, 40000), total: body.length, selection: sel.slice(0, 8000) };
    })()
    """

    @MainActor
    static func extract(from webView: WKWebView) async -> AskPageContent? {
        await withCheckedContinuation { continuation in
            webView.evaluateJavaScript(script) { result, _ in
                guard let dict = result as? [String: Any] else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: AskPageContent(
                    title: dict["title"] as? String ?? "",
                    url: dict["url"] as? String ?? webView.url?.absoluteString ?? "",
                    text: dict["text"] as? String ?? "",
                    selection: dict["selection"] as? String ?? "",
                    totalLength: (dict["total"] as? NSNumber)?.intValue ?? 0
                ))
            }
        }
    }
}

/// Chats with Apple's on-device model about the selected tab's page. Holds one transcript
/// (and model session) per tab, in memory only; it lives as long as the panel is open.
@available(macOS 26.0, *)
@MainActor
@Observable
final class AskPageModel {
    struct Conversation {
        var messages: [AskPageMessage] = []
        var session: LanguageModelSession?
        /// URL of the page the session's context was built from.
        var sessionURL: String?
    }

    /// Character budgets tried in turn for the page text when starting a session.
    /// The model's context is about 4k tokens, shared by instructions, page, question and answer.
    static let pageBudgets = [12_000, 6_000]
    static let selectionBudget = 3_000

    private static let instructions = """
    You answer questions about one web page. Use only the page content given in the prompt, \
    not outside knowledge. If the page does not contain the answer, say that the page doesn't say. \
    When selected text is given, focus on it. Be concise.
    """

    private(set) var conversations: [UUID: Conversation] = [:]
    private(set) var respondingTabId: UUID?
    private var task: Task<Void, Never>?

    func messages(for tabId: UUID) -> [AskPageMessage] {
        conversations[tabId]?.messages ?? []
    }

    var isResponding: Bool { respondingTabId != nil }

    func clear(tabId: UUID) {
        guard respondingTabId != tabId else { return }
        conversations[tabId] = nil
    }

    func stop() {
        task?.cancel()
    }

    /// Asks `question` about the page in `webView`. `label` is what the transcript shows for the
    /// user's turn (for quick actions); `requiresSelection` refuses when nothing is selected.
    func ask(_ question: String, label: String? = nil, requiresSelection: Bool = false, tabId: UUID, webView: WKWebView) {
        guard respondingTabId == nil else { return }
        append(AskPageMessage(role: .user, text: label ?? question), to: tabId)
        respondingTabId = tabId
        task = Task {
            await run(question, requiresSelection: requiresSelection, tabId: tabId, webView: webView)
            respondingTabId = nil
            task = nil
        }
    }

    // MARK: - Private

    private func run(_ question: String, requiresSelection: Bool, tabId: UUID, webView: WKWebView) async {
        guard let page = await AskPageContent.extract(from: webView) else {
            append(AskPageMessage(role: .notice, text: "Couldn't read this page's text.", isError: true), to: tabId)
            return
        }
        if requiresSelection && page.selection.isEmpty {
            append(AskPageMessage(role: .notice, text: "Select some text on the page first, then try again."), to: tabId)
            return
        }
        if page.text.isEmpty && page.selection.isEmpty {
            append(AskPageMessage(role: .notice, text: "This page has no readable text.", isError: true), to: tabId)
            return
        }

        var budgets = Self.pageBudgets
        var reuseSession = conversations[tabId]?.session != nil && conversations[tabId]?.sessionURL == page.url

        while true {
            let session: LanguageModelSession
            let prompt: String
            var note: String?
            if reuseSession, let existing = conversations[tabId]?.session {
                session = existing
                prompt = Self.followUpPrompt(question, page: page)
            } else {
                let budget = budgets.removeFirst()
                let built = Self.initialPrompt(question, page: page, budget: budget)
                prompt = built.prompt
                note = built.note
                session = LanguageModelSession(instructions: Self.instructions)
                let hadSession = conversations[tabId]?.session != nil
                let previousURL = conversations[tabId]?.sessionURL
                conversations[tabId, default: Conversation()].session = session
                conversations[tabId, default: Conversation()].sessionURL = page.url
                if hadSession && previousURL != page.url {
                    insertNoticeBeforeLastQuestion("Now asking about: \(page.title.isEmpty ? page.url : page.title)", tabId: tabId)
                }
            }

            let reply = AskPageMessage(role: .assistant, text: "", note: note)
            append(reply, to: tabId)
            do {
                for try await snapshot in session.streamResponse(to: prompt) {
                    update(reply.id, tabId: tabId) { $0.text = snapshot.content }
                }
                if Task.isCancelled {
                    finishStopped(reply.id, tabId: tabId)
                } else if text(of: reply.id, tabId: tabId).isEmpty {
                    update(reply.id, tabId: tabId) { $0.text = "(No answer.)" }
                }
                return
            } catch {
                if Task.isCancelled || error is CancellationError {
                    finishStopped(reply.id, tabId: tabId)
                    return
                }
                let kind = Self.classify(error)
                if kind == .contextWindow {
                    remove(reply.id, tabId: tabId)
                    if reuseSession {
                        // The conversation filled the context; start over with just this page.
                        reuseSession = false
                        append(AskPageMessage(role: .notice, text: "Started a fresh conversation about this page to fit the model's context."), to: tabId)
                        continue
                    }
                    if !budgets.isEmpty { continue }
                    conversations[tabId]?.session = nil
                }
                let message = Self.message(for: kind, error: error)
                if text(of: reply.id, tabId: tabId).isEmpty {
                    remove(reply.id, tabId: tabId)
                }
                append(AskPageMessage(role: .notice, text: message, isError: true), to: tabId)
                return
            }
        }
    }

    private static func initialPrompt(_ question: String, page: AskPageContent, budget: Int) -> (prompt: String, note: String?) {
        let selection = String(page.selection.prefix(selectionBudget))
        let pageBudget = max(2_000, budget - selection.count)
        let text = String(page.text.prefix(pageBudget))
        let trimmed = page.totalLength > text.count
        var prompt = "Page title: \(page.title)\nURL: \(page.url)\n\n"
        if !selection.isEmpty {
            prompt += "Selected text:\n\"\"\"\n\(selection)\n\"\"\"\n\n"
        }
        prompt += "Page content\(trimmed ? " (only the beginning of the page)" : ""):\n\"\"\"\n\(text)\n\"\"\"\n\n"
        prompt += "Question: \(question)"
        let note = trimmed
            ? "Page text trimmed to the first \(text.count.formatted()) of \(page.totalLength.formatted()) characters."
            : nil
        return (prompt, note)
    }

    private static func followUpPrompt(_ question: String, page: AskPageContent) -> String {
        let selection = String(page.selection.prefix(selectionBudget))
        guard !selection.isEmpty else { return "Question: \(question)" }
        return "Selected text:\n\"\"\"\n\(selection)\n\"\"\"\n\nQuestion: \(question)"
    }

    // MARK: Errors

    private enum ErrorKind { case contextWindow, guardrail, refusal, language, unavailable, other }

    private static func classify(_ error: Error) -> ErrorKind {
        if #available(macOS 27.0, *), let error = error as? LanguageModelError {
            switch error {
            case .contextSizeExceeded: return .contextWindow
            case .guardrailViolation: return .guardrail
            case .refusal: return .refusal
            case .unsupportedLanguageOrLocale: return .language
            default: return .other
            }
        }
        if let error = error as? LanguageModelSession.GenerationError {
            switch error {
            case .exceededContextWindowSize: return .contextWindow
            case .guardrailViolation: return .guardrail
            case .refusal: return .refusal
            case .unsupportedLanguageOrLocale: return .language
            case .assetsUnavailable: return .unavailable
            default: return .other
            }
        }
        return .other
    }

    private static func message(for kind: ErrorKind, error: Error) -> String {
        switch kind {
        case .contextWindow:
            return "This page is too long for the on-device model, even after trimming. Try selecting the part you're interested in."
        case .guardrail:
            return "The on-device model declined to respond because of its safety guardrails. Try a different question or page."
        case .refusal:
            return "The on-device model declined to answer that."
        case .language:
            return "The on-device model doesn't support this page's language yet."
        case .unavailable:
            return "The on-device model isn't ready. Try again in a little while."
        case .other:
            return "Something went wrong: \(error.localizedDescription)"
        }
    }

    // MARK: Transcript editing

    private func append(_ message: AskPageMessage, to tabId: UUID) {
        conversations[tabId, default: Conversation()].messages.append(message)
    }

    private func insertNoticeBeforeLastQuestion(_ text: String, tabId: UUID) {
        guard var messages = conversations[tabId]?.messages,
              let index = messages.lastIndex(where: { $0.role == .user }) else { return }
        messages.insert(AskPageMessage(role: .notice, text: text), at: index)
        conversations[tabId]?.messages = messages
    }

    private func update(_ id: UUID, tabId: UUID, _ change: (inout AskPageMessage) -> Void) {
        guard let index = conversations[tabId]?.messages.firstIndex(where: { $0.id == id }) else { return }
        change(&conversations[tabId]!.messages[index])
    }

    private func remove(_ id: UUID, tabId: UUID) {
        conversations[tabId]?.messages.removeAll { $0.id == id }
    }

    private func text(of id: UUID, tabId: UUID) -> String {
        conversations[tabId]?.messages.first { $0.id == id }?.text ?? ""
    }

    private func finishStopped(_ id: UUID, tabId: UUID) {
        if text(of: id, tabId: tabId).isEmpty { remove(id, tabId: tabId) }
        append(AskPageMessage(role: .notice, text: "Stopped."), to: tabId)
    }
}
