## 1. Page Context

- [x] 1.1 Read title, URL, `document.body.innerText` and selected text from the selected tab's web view with `evaluateJavaScript`
- [x] 1.2 Collapse whitespace and trim page text to a ~12k character budget, keeping the start
- [x] 1.3 Include selected text separately and tell the model to prefer it
- [x] 1.4 Show a note under the answer when the page text was trimmed

## 2. Model

- [x] 2.1 Check `SystemLanguageModel.default.availability` and show a message for each unavailable reason
- [x] 2.2 Create a `LanguageModelSession` with instructions to answer only from the page, say when it doesn't contain the answer, and be concise
- [x] 2.3 Stream answers with `streamResponse` into the transcript
- [x] 2.4 Reuse the session for follow-ups on the same page; start a new one after navigation
- [x] 2.5 On context-window overflow, start a fresh session, then retry with a smaller (6k) budget before giving up
- [x] 2.6 Map guardrail, refusal and unsupported-language errors to readable messages (both `GenerationError` and macOS 27 `LanguageModelError`)

## 3. Panel UI

- [x] 3.1 Right-hand panel in `mainLayout`, toggled by ⇧⌘A and a URL bar button
- [x] 3.2 Quick actions: Summarize, Key points, Explain selection (asks for a selection when there is none)
- [x] 3.3 Stop and Clear buttons
- [x] 3.4 Per-tab transcripts kept in memory while the panel is open

## 4. Availability Gating

- [x] 4.1 Gate model and panel code with `@available(macOS 26.0, *)` / `if #available`
- [x] 4.2 Hide the URL bar button and disable the menu item on older macOS
- [x] 4.3 Weak-link `FoundationModels` in Project.swift

## 5. Verification

- [x] 5.1 Debug build passes
- [ ] 5.2 Manual test on a Mac with Apple Intelligence enabled
