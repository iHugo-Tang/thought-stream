import SwiftUI
import Observation

@Observable
class KnowledgeItem: Identifiable {
    let id = UUID()
    var title: String
    var desc: String
    var tags: [(String, Color)]
    var createdAt: Date
    var isSelected: Bool
    
    init(title: String, desc: String, tags: [(String, Color)], createdAt: Date = Date(), isSelected: Bool = true) {
        self.title = title
        self.desc = desc
        self.tags = tags
        self.createdAt = createdAt
        self.isSelected = isSelected
    }
}

