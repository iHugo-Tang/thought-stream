import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        $inputText.sink { text in
            print("inputText changed to: \(text)")
        }.store(in: &cancellables)
    }
}
