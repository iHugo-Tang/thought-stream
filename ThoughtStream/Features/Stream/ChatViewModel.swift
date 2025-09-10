import Foundation
import Combine
import UIKit

struct Message: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var sendByYou: Bool = false
    var isCommand: Bool = false
}

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private let llm = LLMService()
    private let sessionId: String = UUID().uuidString
    // Track the last processed user message index per command
    private var lastProcessedIndexByCommand: [String: Int] = [:]
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
    }

    func handleAudioSend() {
        print("onAudioSend")
    }

    // MARK: - New handlers with UITextView
    func handleTextSend(_ text: String, textView: UITextView) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let isCmd = isCommandText(trimmed)
        messages.append(Message(text: trimmed, sendByYou: true, isCommand: isCmd))
        textView.text = ""
        textView.delegate?.textViewDidChange?(textView)

        // If it is a recognized command, execute via mock LLM service
        if isCmd {
            Task { [weak self] in
                await self?.executeCommandFor(text: trimmed)
            }
        }
    }

    func handleTextDidChange(_ text: String, textView: UITextView) {
        // Show a slash-command menu when user types '/'
        guard text.last == "/", textView.isFirstResponder else { return }
        (textView as? SlashTextView)?.presentSlashMenu()
    }

    // MARK: - Command detection
    private func isCommandText(_ text: String) -> Bool {
        // Use centralized registry with English keys and localized labels
        return CommandRegistry.isCommandText(text)
    }

    // MARK: - Command execution (mock streaming)
    @MainActor
    private func executeCommandFor(text: String) async {
        let (command, input, lastIdx) = mapCommand(text)
        do {
            let stream = try await llm.executeCommand(
                sessionId: sessionId,
                command: command,
                input: input,
                stream: true
            )
            try await streamAssistantResponse(stream)
            // Mark processed only after successful streaming
            if let li = lastIdx {
                lastProcessedIndexByCommand[command] = li
            }
        } catch {
            messages.append(Message(text: "命令执行失败：\(error.localizedDescription)", sendByYou: false, isCommand: false))
        }
    }

    private func mapCommand(_ text: String) -> (String, [String: Any], Int?) {
        // Resolve command name (English key) from user-visible text
        let commandName: String = CommandRegistry.resolveKey(from: text)
            ?? CommandRegistry.stripSlashPrefix(text)

        // Collect unprocessed user messages (non-command) since last processed index
        let startIdx = (lastProcessedIndexByCommand[commandName] ?? -1) + 1
        var collected: [String] = []
        var lastIncludedIndex: Int? = nil
        if startIdx < messages.count {
            for (idx, msg) in messages.enumerated() where idx >= startIdx {
                guard msg.sendByYou, msg.isCommand == false else { continue }
                collected.append(msg.text)
                lastIncludedIndex = idx
            }
        }

        var input: [String: Any] = [:]
        if !collected.isEmpty {
            input["text"] = collected.joined(separator: "\n\n")
        }

        return (commandName, input, lastIncludedIndex)
    }

    @MainActor
    private func streamAssistantResponse(_ stream: AsyncThrowingStream<String, Error>) async throws {
        // Append a placeholder assistant message we will update incrementally
        var assistant = Message(text: "", sendByYou: false, isCommand: false)
        messages.append(assistant)
        let idx = messages.count - 1

        for try await chunk in stream {
            assistant.text += chunk
            if idx < messages.count {
                messages[idx] = assistant
            }
        }
    }
}
