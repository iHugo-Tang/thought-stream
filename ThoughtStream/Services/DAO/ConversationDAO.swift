import Foundation
import SwiftData

final class ConversationDAO {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func ensureConversation(_ conversation: inout ConversationEntity?) -> ConversationEntity {
        if let conv = conversation { return conv }
        let newConv = ConversationEntity(title: nil)
        context.insert(newConv)
        conversation = newConv
        try? context.save()
        return newConv
    }

    func touch(_ conversation: ConversationEntity) {
        conversation.updatedAt = Date()
        try? context.save()
    }

    func delete(_ conversation: ConversationEntity) -> Bool {
        context.delete(conversation)
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }

    func applyAnalysis(_ analysis: AnalysisData, to conversation: ConversationEntity) {
        if let topic = analysis.suggest_topic, !topic.isEmpty {
            conversation.title = topic
        }
        if let tags = analysis.tags {
            conversation.tags = tags
        }
//        if let reviews = analysis.reviews, !reviews.isEmpty {
//            conversation.summary = reviews.joined(separator: "\n")
//        }
        conversation.updatedAt = Date()
        try? context.save()
    }

    func insertSystemAnalysis(_ analysis: AnalysisData, into conversation: ConversationEntity) {
        if let json = try? JSONEncoder().encode(analysis),
           let jsonText = String(data: json, encoding: .utf8) {
            let sys = SystemMessageEntity(type: "analysis", payload: jsonText, conversation: conversation)
            context.insert(sys)
            try? context.save()
        }
    }
}

