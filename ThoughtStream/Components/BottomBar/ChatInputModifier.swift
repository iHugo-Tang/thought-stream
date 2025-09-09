import SwiftUI
import Combine

extension View {
    func chatInput(
        inputTextPublisher: AnyPublisher<String, Never>? = nil,
        onTextSend: ((String) -> Void)? = nil,
        onAudioSend: (() -> Void)? = nil,
        onTextDidChange: ((String) -> Void)? = nil
    ) -> some View {
        modifier(
            Modifier(
                inputTextPublisher: inputTextPublisher,
                onTextSend: onTextSend,
                onAudioSend: onAudioSend,
                onTextDidChange: onTextDidChange
            )
        )
    }
}

struct Modifier: ViewModifier {
    @State
    private var height: CGFloat?
    private let makeWrapper: (((CGRect) -> Void)?) -> UIKitViewControllerWrapper

    init(
        inputTextPublisher: AnyPublisher<String, Never>? = nil,
        onTextSend: ((String) -> Void)? = nil,
        onAudioSend: (() -> Void)? = nil,
        onTextDidChange: ((String) -> Void)? = nil
    ) {
        self.makeWrapper = { onBottomViewFrameChanged in
            UIKitViewControllerWrapper(
                inputTextPublisher: inputTextPublisher,
                onTextSend: onTextSend,
                onAudioSend: onAudioSend,
                onTextDidChange: onTextDidChange,
                onBottomViewFrameChanged: onBottomViewFrameChanged
            )
        }
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            content
                .safeAreaPadding(.bottom, height)
            makeWrapper({ bottomViewFrame in
                height = bottomViewFrame.height
            })
        }
        .ignoresSafeArea(.all, edges: .bottom) // this is for SwiftUI layout interactive dissmissing animation bug
    }
}

struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    let onBottomViewFrameChanged: ((CGRect) -> Void)?
    let inputTextPublisher: AnyPublisher<String, Never>?
    let onTextSend: ((String) -> Void)?
    let onAudioSend: (() -> Void)?
    let onTextDidChange: ((String) -> Void)?

    init(
        inputTextPublisher: AnyPublisher<String, Never>? = nil,
        onTextSend: ((String) -> Void)? = nil,
        onAudioSend: (() -> Void)? = nil,
        onTextDidChange: ((String) -> Void)? = nil,
        onBottomViewFrameChanged: ((CGRect) -> Void)? = nil
    ) {
        self.onBottomViewFrameChanged = onBottomViewFrameChanged
        self.inputTextPublisher = inputTextPublisher
        self.onTextSend = onTextSend
        self.onAudioSend = onAudioSend
        self.onTextDidChange = onTextDidChange
    }

    func makeUIViewController(context: Context) -> ChatInputViewController {
        return ChatInputViewController(
            inputTextPublisher: inputTextPublisher,
            onTextSend: onTextSend,
            onAudioSend: onAudioSend,
            onTextDidChange: onTextDidChange,
            onBottomViewFrameChanged: onBottomViewFrameChanged
        )
    }

    func updateUIViewController(_ uiViewController: ChatInputViewController, context: Context) {
        // Handle state updates here if needed
    }
}
