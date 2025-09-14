import Foundation

struct Message: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var sendByYou: Bool = false
    var command: CommandDef?
    var isCommand: Bool { command != nil }
}


