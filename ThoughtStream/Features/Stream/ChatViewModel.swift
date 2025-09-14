import Foundation
import Combine
#if canImport(UIKit)
import UIKit
#endif
import SwiftData

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var errorMessage: String?
    private let llm = LLMService()
    private var sessionId: String = UUID().uuidString

    // Persistence
    private var modelContext: ModelContext?
    private(set) var conversation: ConversationEntity?
    private var entityByMessageId: [UUID: ChatMessageEntity] = [:]
    private var conversationDAO: ConversationDAO?
    private var messageDAO: MessageDAO?

    // Trackers removed for simplicity
    
    var cancellables: Set<AnyCancellable> = []
    
    init(conversation: ConversationEntity? = nil) {
        self.conversation = conversation
    }

    // Bind context and ensure conversation exists; then load persisted messages
    @MainActor
    func bind(modelContext: ModelContext) {
        guard self.modelContext == nil else { return }
        self.modelContext = modelContext
        self.conversationDAO = ConversationDAO(context: modelContext)
        self.messageDAO = MessageDAO(context: modelContext)

        if let conv = conversation {
            sessionId = conv.id.uuidString
            loadPersistedMessages()
        }
    }

    @MainActor
    private func loadPersistedMessages() {
        guard let dao = messageDAO, let conv = conversation else { return }
        do {
            let (ui, map) = try dao.uiMessages(for: conv)
            entityByMessageId = map
            messages = ui
        } catch {
            // swallow to keep UI simple
        }
    }

    func handleAudioSend() {
        print("onAudioSend")
    }

    // MARK: - New handlers with UITextView
    #if canImport(UIKit)
    @MainActor
    func handleTextSend(_ text: String, textView: UITextView) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let isCmd = isCommandText(trimmed)
        let key = CommandRegistry.resolveKey(from: trimmed)
        let cmdDef = key.flatMap { CommandRegistry.command(for: $0) }

        let uiMsg = Message(text: trimmed, sendByYou: true, command: cmdDef)
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
    #endif

    // MARK: - Command detection
    private func isCommandText(_ text: String) -> Bool {
        // Use centralized registry with English keys and localized labels
        return CommandRegistry.isCommandText(text)
    }

    // MARK: - Command execution (mock streaming)
    @MainActor
    private func executeCommandFor(text: String) async {
        let (command, input) = mapCommand(text)
        do {
            let result = try await llm.executeCommand(
                sessionId: sessionId,
                command: command,
                input: input,
                stream: true
            )
            try await streamAssistantResponse(result.stream)
            if let analysis = result.analysis {
                await persistAnalysis(analysis)
            }
            touchConversation()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func mapCommand(_ text: String) -> (String, [String: Any]) {
        // Resolve command name (English key) from user-visible text
        let commandName: String = CommandRegistry.resolveKey(from: text)
            ?? CommandRegistry.stripSlashPrefix(text)
        var input: [String: Any] = [:]
        input["messages"] = messages
        return (commandName, input)
    }

    @MainActor
    private func streamAssistantResponse(_ stream: AsyncThrowingStream<String, Error>) async throws {
        // Append a placeholder assistant message we will update incrementally
        var assistant = Message(text: "", sendByYou: false, command: nil)
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
        guard let convDAO = conversationDAO, let msgDAO = messageDAO else { return }
        let conv = convDAO.ensureConversation(&conversation)
        sessionId = conv.id.uuidString
        let entity = msgDAO.insert(uiMessage: ui, into: conv)
        entityByMessageId[ui.id] = entity
        touchConversation()
    }

    @MainActor
    private func updatePersisted(for ui: Message) {
        guard let msgDAO = messageDAO, let entity = entityByMessageId[ui.id] else { return }
        msgDAO.update(entity: entity, text: ui.text)
    }

    @MainActor
    private func touchConversation() {
        guard let convDAO = conversationDAO, let conv = conversation else { return }
        convDAO.touch(conv)
    }

    // MARK: - Persist Analysis to system message and conversation metadata
    @MainActor
    private func persistAnalysis(_ analysis: AnalysisData) async {
        guard let convDAO = conversationDAO else { return }
        let conv = convDAO.ensureConversation(&conversation)
        sessionId = conv.id.uuidString
        convDAO.applyAnalysis(analysis, to: conv)
        convDAO.insertSystemAnalysis(analysis, into: conv)
    }

    // MARK: - Delete conversation
    @MainActor
    func deleteConversation() -> Bool {
        guard let convDAO = conversationDAO, let conv = conversation else { return false }
        return convDAO.delete(conv)
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
