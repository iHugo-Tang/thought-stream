import Foundation

struct Message: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var sendByYou: Bool = false
    var command: CommandDef?
    var isCommand: Bool { command != nil }
    var systemMessage: SystemMessageEntity?
    
    var analysis: AnalysisData? { systemMessage?.analysis }

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


