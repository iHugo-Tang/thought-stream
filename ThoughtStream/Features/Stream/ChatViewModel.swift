import Foundation
import Combine
import UIKit

struct Message: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var sendByYou: Bool = false
}

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
    }

    func handleAudioSend() {
        print("onAudioSend")
    }

    // MARK: - New handlers with UITextView
    func handleTextSend(_ text: String, textView: UITextView) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(Message(text: trimmed, sendByYou: true))
        textView.text = ""
        textView.delegate?.textViewDidChange?(textView)
    }

    func handleTextDidChange(_ text: String, textView: UITextView) {
    }
}
