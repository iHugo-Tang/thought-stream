import Foundation
import SwiftData

@Model
final class ConversationEntity {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String?
    var summary: String?
    var tags: [String] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \ChatMessageEntity.conversation)
    var messages: [ChatMessageEntity] = []

    init(title: String? = nil, summary: String? = nil, tags: [String] = []) {
        self.title = title
        self.summary = summary
        self.tags = tags
    }
    
    var displayTitle: String {
        return title ?? "Untitled Conversation"
    }
    
    var displayBodyText: String {
        if let summary = summary, !summary.isEmpty {
            return summary
        }
        
        // Fallback to first user message if no summary
        let userMessage = messages.first { $0.sendByYou && !$0.isCommand }
        return userMessage?.text ?? ""
    }
    
    var formattedDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy - h:mm a"
        return formatter.string(from: updatedAt)
    }
}

@Model
final class ChatMessageEntity {
    @Attribute(.unique) var id: UUID = UUID()
    var text: String
    var sendByYou: Bool
    var isCommand: Bool
    var createdAt: Date = Date()

    @Relationship var conversation: ConversationEntity?
    var systemMessage: SystemMessageEntity?

    init(text: String, sendByYou: Bool, isCommand: Bool, conversation: ConversationEntity?, systemMessage: SystemMessageEntity? = nil) {
        self.text = text
        self.sendByYou = sendByYou
        self.isCommand = isCommand
        self.conversation = conversation
        self.systemMessage = systemMessage
    }
}

@Model
final class SystemMessageEntity {
    @Attribute(.unique) var id: UUID = UUID()
    var type: String // e.g., "analysis"
    var payload: String // raw JSON or text
    var createdAt: Date = Date()

    @Relationship var conversation: ConversationEntity?
    var messages: ChatMessageEntity?

    init(type: String, payload: String, conversation: ConversationEntity?) {
        self.type = type
        self.payload = payload
        self.conversation = conversation
    }
}

extension SystemMessageEntity {
    var analysis: AnalysisData? {
        guard type == "analysis", let data = payload.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(AnalysisData.self, from: data)
    }
}

@Model
final class PendingSystemTaskEntity {
    @Attribute(.unique) var id: UUID = UUID()
    var commandKey: String
    var status: String // "loading" | "error"
    var errorMessage: String?
    var createdAt: Date = Date()

    @Relationship var conversation: ConversationEntity?

    init(commandKey: String, status: String, errorMessage: String? = nil, conversation: ConversationEntity?) {
        self.commandKey = commandKey
        self.status = status
        self.errorMessage = errorMessage
        self.conversation = conversation
    }
}
