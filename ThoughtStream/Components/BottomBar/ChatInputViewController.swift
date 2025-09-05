import UIKit
import SwiftUI

class ChatInputViewController: UIViewController, UITextViewDelegate {
    var rowHeight : CGFloat = 14
    var baseHeight: CGFloat = 30
    var maxHeight: CGFloat = 30
    let chatInputView: ChatInputView!
    
    init(onBottomViewFrameChanged: ((CGRect) -> Void)?) {
        self.chatInputView = ChatInputView(onBottomViewFrameChanged: onBottomViewFrameChanged)
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
