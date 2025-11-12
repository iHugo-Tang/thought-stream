import Foundation
import SwiftData

final class SystemTaskDAO {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func upsertLoading(for conversation: ConversationEntity, commandKey: String) -> PendingSystemTaskEntity {
        if let existing = fetchPending(for: conversation) {
            existing.commandKey = commandKey
            existing.status = "loading"
            existing.errorMessage = nil
            try? context.save()
            return existing
        }
        let e = PendingSystemTaskEntity(commandKey: commandKey, status: "loading", conversation: conversation)
        context.insert(e)
        try? context.save()
        return e
    }

    func markError(_ task: PendingSystemTaskEntity, message: String) {
        task.status = "error"
        task.errorMessage = message
        try? context.save()
    }

    func clear(_ task: PendingSystemTaskEntity) {
        context.delete(task)
        try? context.save()
    }

    func fetchPending(for conversation: ConversationEntity) -> PendingSystemTaskEntity? {
        let conversationId = conversation.id
        let descriptor = FetchDescriptor<PendingSystemTaskEntity>(
            predicate: #Predicate<PendingSystemTaskEntity> { task in
                task.conversation?.id == conversationId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try? context.fetch(descriptor).first
    }
}

