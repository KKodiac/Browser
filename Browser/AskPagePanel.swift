import FoundationModels
import SwiftUI
import WebKit

/// Right-hand side panel for chatting with the on-device model about the selected tab's page.
/// Transcripts are kept per tab while the panel is open and dropped when it closes.
@available(macOS 26.0, *)
struct AskPagePanel: View {
    var tabId: UUID
    /// The selected tab's web view; nil (or a tab with no page) disables asking.
    var webView: WKWebView?
    var hasPage: Bool
    var accentColor: Color
    var onDismiss: () -> Void

    @State private var model = AskPageModel()
    @State private var input = ""
    @FocusState private var inputFocused: Bool

    private struct QuickAction {
        let label: String
        let prompt: String
        var requiresSelection = false
    }

    private static let quickActions = [
        QuickAction(label: "Summarize", prompt: "Summarize this page in a short paragraph."),
        QuickAction(label: "Key points", prompt: "List the key points of this page as short bullet points."),
        QuickAction(label: "Explain selection", prompt: "Explain the selected text in plain language.", requiresSelection: true),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            if let message = unavailableMessage {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                transcript
                Divider()
                quickActionBar
                inputRow
            }
        }
        .frame(width: 320)
        .background(.ultraThinMaterial)
        .onAppear { inputFocused = true }
        .onDisappear { model.stop() }
    }

    private var messages: [AskPageMessage] { model.messages(for: tabId) }
    private var isRespondingHere: Bool { model.respondingTabId == tabId }
    private var canAsk: Bool { hasPage && webView != nil && !model.isResponding }

    private var unavailableMessage: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(.deviceNotEligible):
            return "This Mac doesn't support Apple Intelligence, so Ask This Page isn't available."
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Turn on Apple Intelligence in System Settings to ask about pages."
        case .unavailable(.modelNotReady):
            return "The on-device model is still downloading or getting ready. Try again in a little while."
        case .unavailable:
            return "The on-device model isn't available right now."
        }
    }

    private var header: some View {
        HStack {
            Label("Ask This Page", systemImage: "sparkles")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Button("Clear") { model.clear(tabId: tabId) }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .disabled(messages.isEmpty || isRespondingHere)
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .medium))
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Close")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var transcript: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    if messages.isEmpty {
                        Text(hasPage
                             ? "Ask a question about this page. Answers come from Apple's on-device model and use only the page's text."
                             : "Open a page to ask about it.")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    ForEach(messages) { message in
                        messageView(message).id(message.id)
                    }
                    if isRespondingHere && (messages.last?.role != .assistant || messages.last?.text.isEmpty == true) {
                        ProgressView().controlSize(.small)
                    }
                }
                .padding(12)
            }
            .frame(maxHeight: .infinity)
            .onChange(of: messages) { _, newValue in
                if let last = newValue.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    @ViewBuilder
    private func messageView(_ message: AskPageMessage) -> some View {
        switch message.role {
        case .user:
            HStack {
                Spacer(minLength: 40)
                Text(message.text)
                    .font(.system(size: 12))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(accentColor.opacity(0.25), in: .rect(cornerRadius: 10, style: .continuous))
                    .textSelection(.enabled)
            }
        case .assistant:
            VStack(alignment: .leading, spacing: 4) {
                Text(Self.markdown(message.text))
                    .font(.system(size: 12))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let note = message.note {
                    Text(note)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }
        case .notice:
            Text(message.text)
                .font(.system(size: 11))
                .foregroundStyle(message.isError ? Color.orange : Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var quickActionBar: some View {
        HStack(spacing: 6) {
            ForEach(Self.quickActions, id: \.label) { action in
                Button(action.label) {
                    ask(action.prompt, label: action.label, requiresSelection: action.requiresSelection)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.07), in: Capsule())
                .disabled(!canAsk)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private var inputRow: some View {
        HStack(alignment: .bottom, spacing: 6) {
            TextField("Ask about this page", text: $input, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.07), in: .rect(cornerRadius: 10, style: .continuous))
                .focused($inputFocused)
                .onSubmit(submit)
            if isRespondingHere {
                Button(action: { model.stop() }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
                .help("Stop")
            } else {
                Button(action: submit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(accentColor)
                }
                .buttonStyle(.plain)
                .disabled(!canAsk || input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .help("Ask")
            }
        }
        .padding(12)
    }

    private func submit() {
        let question = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, canAsk else { return }
        input = ""
        ask(question)
    }

    private func ask(_ prompt: String, label: String? = nil, requiresSelection: Bool = false) {
        guard canAsk, let webView else { return }
        model.ask(prompt, label: label, requiresSelection: requiresSelection, tabId: tabId, webView: webView)
    }

    private static func markdown(_ text: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
    }
}
