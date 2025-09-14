import Foundation
import SwiftData

final class MessageDAO {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchEntities(for conversation: ConversationEntity) throws -> [ChatMessageEntity] {
        let conversationId = conversation.id
        let descriptor = FetchDescriptor<ChatMessageEntity>(
            predicate: #Predicate<ChatMessageEntity> { message in
                message.conversation?.id == conversationId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try context.fetch(descriptor)
    }

    func uiMessages(for conversation: ConversationEntity) throws -> (messages: [Message], entityById: [UUID: ChatMessageEntity]) {
        let entities = try fetchEntities(for: conversation)
        var ui: [Message] = []
        var map: [UUID: ChatMessageEntity] = [:]
        for e in entities {
            let cmdDef: CommandDef? = e.isCommand ? (CommandRegistry.resolveKey(from: e.text).flatMap { CommandRegistry.command(for: $0) }) : nil
            let m = Message(id: e.id, text: e.text, sendByYou: e.sendByYou, command: cmdDef)
            ui.append(m)
            map[m.id] = e
        }
        return (ui, map)
    }

    func insert(uiMessage: Message, into conversation: ConversationEntity) -> ChatMessageEntity {
        let entity = ChatMessageEntity(text: uiMessage.text, sendByYou: uiMessage.sendByYou, isCommand: uiMessage.isCommand, conversation: conversation)
        entity.id = uiMessage.id
        context.insert(entity)
        try? context.save()
        return entity
    }

    func update(entity: ChatMessageEntity, text: String) {
        if entity.text != text {
            entity.text = text
            try? context.save()
        }
    }
}

