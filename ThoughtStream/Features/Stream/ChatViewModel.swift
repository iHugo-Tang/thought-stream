import Foundation
import Combine
import UIKit
import SwiftData

struct Message: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var sendByYou: Bool = false
    var isCommand: Bool = false
}

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private let llm = LLMService()
    private var sessionId: String = UUID().uuidString

    // Persistence
    private var modelContext: ModelContext?
    private(set) var conversation: ConversationEntity?
    private var entityByMessageId: [UUID: ChatMessageEntity] = [:]

    // Track the last processed user message index per command
    private var lastProcessedIndexByCommand: [String: Int] = [:]
    
    var cancellables: Set<AnyCancellable> = []
    
    init(conversation: ConversationEntity? = nil) {
        self.conversation = conversation
    }

    // Bind context and ensure conversation exists; then load persisted messages
    @MainActor
    func bind(modelContext: ModelContext) {
        guard self.modelContext == nil else { return }
        self.modelContext = modelContext

        if conversation == nil {
            let conv = ConversationEntity(title: nil)
            modelContext.insert(conv)
            conversation = conv
            try? modelContext.save()
        }
        if let conv = conversation {
            sessionId = conv.id.uuidString
        }
        loadPersistedMessages()
    }

    @MainActor
    private func loadPersistedMessages() {
        guard let ctx = modelContext, let conv = conversation else { return }
        let conversationId = conv.id
        let descriptor = FetchDescriptor<ChatMessageEntity>(
            predicate: #Predicate<ChatMessageEntity> { message in
                message.conversation?.id == conversationId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        do {
            let entities = try ctx.fetch(descriptor)
            var ui: [Message] = []
            entityByMessageId.removeAll(keepingCapacity: true)
            for e in entities {
                let m = Message(id: e.id, text: e.text, sendByYou: e.sendByYou, isCommand: e.isCommand)
                ui.append(m)
                entityByMessageId[m.id] = e
            }
            messages = ui
        } catch {
            // swallow to keep UI simple
        }
    }

    func handleAudioSend() {
        print("onAudioSend")
    }

    // MARK: - New handlers with UITextView
    @MainActor
    func handleTextSend(_ text: String, textView: UITextView) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let isCmd = isCommandText(trimmed)

        let uiMsg = Message(text: trimmed, sendByYou: true, isCommand: isCmd)
        messages.append(uiMsg)
        persist(uiMsg)

        textView.text = ""
        textView.delegate?.textViewDidChange?(textView)

        // If it is a recognized command, execute via mock LLM service
        if isCmd {
            Task { [weak self] in
                await self?.executeCommandFor(text: trimmed)
            }
        }
    }

    @MainActor
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
            touchConversation()
        } catch {
            let uiMsg = Message(text: "命令执行失败：\(error.localizedDescription)", sendByYou: false, isCommand: false)
            messages.append(uiMsg)
            persist(uiMsg)
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
        persist(assistant, asPlaceholder: true)

        let idx = messages.count - 1

        for try await chunk in stream {
            assistant.text += chunk
            if idx < messages.count {
                messages[idx] = assistant
            }
            // update the persisted placeholder text
            updatePersisted(for: assistant)
        }
    }

    // MARK: - Persistence helpers
    @MainActor
    private func persist(_ ui: Message, asPlaceholder: Bool = false) {
        guard let ctx = modelContext, let conv = conversation else { return }
        let entity = ChatMessageEntity(text: ui.text, sendByYou: ui.sendByYou, isCommand: ui.isCommand, conversation: conv)
        // align ids to keep mapping stable
        entity.id = ui.id
        ctx.insert(entity)
        entityByMessageId[ui.id] = entity
        touchConversation()
        try? ctx.save()
    }

    @MainActor
    private func updatePersisted(for ui: Message) {
        guard let ctx = modelContext, let entity = entityByMessageId[ui.id] else { return }
        if entity.text != ui.text {
            entity.text = ui.text
            try? ctx.save()
        }
    }

    @MainActor
    private func touchConversation() {
        guard let ctx = modelContext, let conv = conversation else { return }
        conv.updatedAt = Date()
        try? ctx.save()
    }
}

extension ChatViewModel {
    /// Compose current conversation as plain text for export.
    /// Format: "You:" / "Assistant:" prefixes and skip command messages.
    func exportText() -> String {
        var lines: [String] = []
        for message in messages {
            if message.isCommand { continue }
            let role = message.sendByYou ? "You" : "Assistant"
            lines.append("\(role): \(message.text)")
        }
        return lines.joined(separator: "\n\n")
    }
}
