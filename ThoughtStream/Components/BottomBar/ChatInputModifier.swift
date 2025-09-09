import SwiftUI

extension View {
    func chatInput(chatViewModel: ChatViewModel? = nil) -> some View {
        modifier(Modifier(chatViewModel: chatViewModel))
    }
}

struct Modifier: ViewModifier {
    @State
    private var height: CGFloat?
    private let chatViewModel: ChatViewModel?

    init(chatViewModel: ChatViewModel? = nil) {
        self.chatViewModel = chatViewModel
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            content
                .safeAreaPadding(.bottom, height)
            UIKitViewControllerWrapper(chatViewModel: chatViewModel) { bottomViewFrame in
                height = bottomViewFrame.height
            }
        }
        .ignoresSafeArea(.all, edges: .bottom) // this is for SwiftUI layout interactive dissmissing animation bug
    }
}

struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    let chatViewModel: ChatViewModel?
    let onBottomViewFrameChanged: ((CGRect) -> Void)?

    init(chatViewModel: ChatViewModel? = nil, onBottomViewFrameChanged: ((CGRect) -> Void)? = nil) {
        self.chatViewModel = chatViewModel
        self.onBottomViewFrameChanged = onBottomViewFrameChanged
    }

    func makeUIViewController(context: Context) -> ChatInputViewController {
        return ChatInputViewController(chatViewModel: chatViewModel, onBottomViewFrameChanged: onBottomViewFrameChanged)
    }

    func updateUIViewController(_ uiViewController: ChatInputViewController, context: Context) {
        // 这里可以处理状态更新
    }
}
