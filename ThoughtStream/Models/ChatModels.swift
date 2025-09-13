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

    init(text: String, sendByYou: Bool, isCommand: Bool, conversation: ConversationEntity?) {
        self.text = text
        self.sendByYou = sendByYou
        self.isCommand = isCommand
        self.conversation = conversation
    }
}
