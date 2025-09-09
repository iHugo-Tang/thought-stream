import UIKit
import SwiftUI
import Combine

class ChatInputViewController: UIViewController, UITextViewDelegate {
    var rowHeight : CGFloat = 14
    var baseHeight: CGFloat = 30
    var maxHeight: CGFloat = 30
    let chatInputView: ChatInputView!

    init(
        inputTextPublisher: AnyPublisher<String, Never>? = nil,
        onTextSend: ((String) -> Void)? = nil,
        onAudioSend: (() -> Void)? = nil,
        onTextDidChange: ((String) -> Void)? = nil,
        onBottomViewFrameChanged: ((CGRect) -> Void)?
    ) {
        self.chatInputView = ChatInputView(
            inputTextPublisher: inputTextPublisher,
            onTextSend: onTextSend,
            onAudioSend: onAudioSend,
            onTextDidChange: onTextDidChange,
            onBottomViewFrameChanged: onBottomViewFrameChanged
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = chatInputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

#Preview {
    ChatView()
}
