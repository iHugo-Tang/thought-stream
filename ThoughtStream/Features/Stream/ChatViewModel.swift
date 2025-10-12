import Foundation
import Combine
#if canImport(UIKit)
import UIKit
#endif
import SwiftData

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var errorMessage: String?
    enum SystemStatus: Equatable {
        case loading(String)
        case error(String)
    }
    @Published var systemStatus: SystemStatus?
    private let llm = LLMService()
    private var sessionId: String = UUID().uuidString
    private var currentRequest: (command: String, input: [String: Any])?

    // Persistence
    private var modelContext: ModelContext?
    private(set) var conversation: ConversationEntity?
    private var entityByMessageId: [UUID: ChatMessageEntity] = [:]
    private var conversationDAO: ConversationDAO?
    private var messageDAO: MessageDAO?
    private var systemTaskDAO: SystemTaskDAO?
    private var pendingTaskEntity: PendingSystemTaskEntity?

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
        self.systemTaskDAO = SystemTaskDAO(context: modelContext)

        if let conv = conversation {
            sessionId = conv.id.uuidString
            loadPersistedMessages()
            // Load any pending system task for resume/retry
            if let task = systemTaskDAO?.fetchPending(for: conv) {
                pendingTaskEntity = task
                updateSystemStatus(from: task)
            }
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

        // If it is a recognized command, execute via LLM service
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
            currentRequest = (command, input)
            let conv = conversationDAO!.ensureConversation(&conversation)
            sessionId = conv.id.uuidString
            let task = systemTaskDAO!.upsertLoading(for: conv, commandKey: command)
            pendingTaskEntity = task
            await MainActor.run { self.systemStatus = .loading(self.loadingText(for: command)) }
            let result = try await llm.executeCommand(
                sessionId: sessionId,
                command: command,
                input: input
            )
            await MainActor.run { self.systemStatus = nil }
            var systemMessageEntity: SystemMessageEntity?
            if let analysis = result.analysis {
                systemMessageEntity = await persistAnalysis(analysis)
            }
            // 一次性追加助手消息（非流式）
            let assistant = Message(text: result.text, sendByYou: false, command: nil, systemMessage: systemMessageEntity)
            messages.append(assistant)
            persist(assistant)
            touchConversation()
            currentRequest = nil
            if let e = pendingTaskEntity { systemTaskDAO?.clear(e); pendingTaskEntity = nil }
        } catch {
            await MainActor.run {
                self.systemStatus = .error(self.errorText(for: command))
                self.errorMessage = error.localizedDescription
            }
            if let e = pendingTaskEntity { systemTaskDAO?.markError(e, message: error.localizedDescription) }
        }
    }

    // Allow user to retry the last failed command
    @MainActor
    func retryCurrentSystemTask() {
        // Prefer persisted task so retry works after relaunch
        if let task = pendingTaskEntity ?? (conversation.flatMap { systemTaskDAO?.fetchPending(for: $0) }) {
            let commandKey = task.commandKey
            let (command, input) = mapCommandFromKey(commandKey)
            Task { [weak self] in
                guard let self else { return }
                await MainActor.run { self.systemStatus = .loading(self.loadingText(for: commandKey)) }
                do {
                    let result = try await self.llm.executeCommand(
                        sessionId: self.sessionId,
                        command: command,
                        input: input
                    )
                    await MainActor.run { self.systemStatus = nil }
                    var systemMessageEntity: SystemMessageEntity?
                    if let analysis = result.analysis {
                        systemMessageEntity = await persistAnalysis(analysis)
                    }
                    let assistant = Message(text: result.text, sendByYou: false, command: nil, systemMessage: systemMessageEntity)
                    self.messages.append(assistant)
                    self.persist(assistant)
                    self.touchConversation()
                    if let e = self.pendingTaskEntity ?? (self.conversation.flatMap { self.systemTaskDAO?.fetchPending(for: $0) }) {
                        self.systemTaskDAO?.clear(e)
                        self.pendingTaskEntity = nil
                    }
                } catch {
                    await MainActor.run {
                        self.systemStatus = .error(self.errorText(for: commandKey))
                        self.errorMessage = error.localizedDescription
                    }
                    if let e = self.pendingTaskEntity ?? (self.conversation.flatMap { self.systemTaskDAO?.fetchPending(for: $0) }) {
                        self.systemTaskDAO?.markError(e, message: error.localizedDescription)
                    }
                }
            }
            return
        }
        // Fallback to in-memory request if exists
        guard let req = currentRequest else { return }
        Task { [weak self] in
            guard let self else { return }
            await MainActor.run { self.systemStatus = .loading(self.loadingText(for: req.command)) }
            do {
                let result = try await self.llm.executeCommand(
                    sessionId: self.sessionId,
                    command: req.command,
                    input: req.input
                )
                await MainActor.run { self.systemStatus = nil }
                var systemMessageEntity: SystemMessageEntity?
                if let analysis = result.analysis {
                    systemMessageEntity = await persistAnalysis(analysis)
                }
                let assistant = Message(text: result.text, sendByYou: false, command: nil, systemMessage: systemMessageEntity)
                self.messages.append(assistant)
                self.persist(assistant)
                self.touchConversation()
                self.currentRequest = nil
            } catch {
                await MainActor.run {
                    self.systemStatus = .error(self.errorText(for: req.command))
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func mapCommandFromKey(_ key: String) -> (String, [String: Any]) {
        var input: [String: Any] = [:]
        input["messages"] = messages
        return (key, input)
    }

    private func updateSystemStatus(from task: PendingSystemTaskEntity) {
        switch task.status {
        case "loading":
            systemStatus = .loading(loadingText(for: task.commandKey))
        case "error":
            systemStatus = .error(errorText(for: task.commandKey))
            errorMessage = task.errorMessage
        default:
            break
        }
    }

    private func loadingText(for commandKey: String) -> String {
        let label = CommandRegistry.displayName(for: commandKey)
        return "Analyzing… (\(label))"
    }

    private func errorText(for commandKey: String) -> String {
        let label = CommandRegistry.displayName(for: commandKey)
        return "分析失败 (\(label))"
    }

    private func mapCommand(_ text: String) -> (String, [String: Any]) {
        // Resolve command name (English key) from user-visible text
        let commandName: String = CommandRegistry.resolveKey(from: text)
            ?? CommandRegistry.stripSlashPrefix(text)
        var input: [String: Any] = [:]
        input["messages"] = messages
        return (commandName, input)
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
    private func persistAnalysis(_ analysis: AnalysisData) async -> SystemMessageEntity? {
        guard let convDAO = conversationDAO else { return nil }
        let conv = convDAO.ensureConversation(&conversation)
        sessionId = conv.id.uuidString
        convDAO.applyAnalysis(analysis, to: conv)
        return convDAO.insertSystemAnalysis(analysis, into: conv)
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
