## Why

Reading a long page to find one answer is slow. Users want to ask questions about the page they're on, get a summary, or have a confusing passage explained, without sending the page to a server. macOS 26 ships Apple's on-device language model (Foundation Models), so this can run entirely on the Mac, including in private windows.

## What Changes

- Add an "Ask This Page" side panel on the right of the window, toggled with ⇧⌘A (View menu) or a sparkles button in the URL bar
- When a question is asked, read the selected tab's title, URL, `document.body.innerText` and any selected text with JavaScript; trim the page text to a ~12k character budget (keeping the start) and say under the answer when it was trimmed
- Quick actions above the input: Summarize, Key points, Explain selection
- Stream answers from `LanguageModelSession.streamResponse` into the panel, with Stop and Clear
- Keep one transcript and model session per tab while the panel is open (in memory only); a new tab starts a fresh conversation, navigating starts a fresh session
- Instruct the model to answer only from the page content, say when the page doesn't contain the answer, and be concise
- Check `SystemLanguageModel.default.availability` and explain when Apple Intelligence is off, the Mac isn't eligible, or the model isn't ready; turn context-window, guardrail, refusal and language errors into readable messages
- Gate everything on macOS 26 (`@available`); on older macOS the button is hidden and the menu item disabled

## Capabilities

### New Capabilities
- `ask-page`: On-device chat panel about the current page: page text extraction, prompt budget, streaming, per-tab transcripts, availability and error handling

### Modified Capabilities
_(none — no existing spec requirements change)_

## Impact

- **AskPageModel.swift** (new): page extraction script, prompt building, per-tab conversations and sessions, error mapping
- **AskPagePanel.swift** (new): panel UI (header, transcript, quick actions, input, Stop/Clear, availability message)
- **ContentView.swift**: panel on the right of `mainLayout`, URL bar button, `onChange` for the menu trigger
- **AppFeature.swift**: `toggleAskPage` action and `toggleAskPageTrigger` counter
- **BrowserApp.swift**: View > Ask This Page (⇧⌘A), disabled before macOS 26
- **Project.swift**: weak-linked `FoundationModels` SDK dependency
- Nothing is persisted; private windows can use the panel because everything stays on device
