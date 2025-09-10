import Foundation
import Combine
import UIKit

struct Message: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var sendByYou: Bool = false
    var isCommand: Bool = false
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
        let isCmd = isCommandText(trimmed)
        messages.append(Message(text: trimmed, sendByYou: true, isCommand: isCmd))
        textView.text = ""
        textView.delegate?.textViewDidChange?(textView)
    }

    func handleTextDidChange(_ text: String, textView: UITextView) {
        // Show a slash-command menu when user types '/'
        guard text.last == "/", textView.isFirstResponder else { return }
        (textView as? SlashTextView)?.presentSlashMenu()
    }

    // MARK: - Command detection
    private func isCommandText(_ text: String) -> Bool {
        // Simple matcher for known commands; extend as you add more
        let commands: Set<String> = ["地道英语"]
        return commands.contains(text) || text.hasPrefix("⌘ /")
    }
}
