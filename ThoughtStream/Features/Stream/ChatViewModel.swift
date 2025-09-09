import Foundation
import Combine

struct Message: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var sendByYou: Bool = false
}

class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var messages: [Message] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        $inputText.sink { text in
            print("inputText changed to: \(text)")
        }.store(in: &cancellables)
    }
}
