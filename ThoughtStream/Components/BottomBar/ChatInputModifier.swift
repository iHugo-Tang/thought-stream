import SwiftUI
import Combine
import UIKit

extension View {
    func chatInput(
        onTextSend: ((String, UITextView) -> Void)? = nil,
        onAudioSend: (() -> Void)? = nil,
        onTextDidChange: ((String, UITextView) -> Void)? = nil,
    ) -> some View {
        modifier(
            Modifier(
                onTextSend: onTextSend,
                onTextDidChange: onTextDidChange,
                onAudioSend: onAudioSend,
            )
        )
    }
}

struct Modifier: ViewModifier {
    @State
    private var height: CGFloat?
    private let makeWrapper: (((CGRect) -> Void)?) -> UIKitViewControllerWrapper

    init(
        onTextSend: ((String, UITextView) -> Void)? = nil,
        onTextDidChange: ((String, UITextView) -> Void)? = nil,
        onAudioSend: (() -> Void)? = nil,
    ) {
        self.makeWrapper = { onBottomViewFrameChanged in
            UIKitViewControllerWrapper(
                onTextSend: onTextSend,
                onTextDidChange: onTextDidChange,
                onAudioSend: onAudioSend,
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
    let onTextSend: ((String, UITextView) -> Void)?
    let onTextDidChange: ((String, UITextView) -> Void)?
    let onAudioSend: (() -> Void)?

    init(
        onTextSend: ((String, UITextView) -> Void)? = nil,
        onTextDidChange: ((String, UITextView) -> Void)? = nil,
        onAudioSend: (() -> Void)? = nil,
        onBottomViewFrameChanged: ((CGRect) -> Void)? = nil
    ) {
        self.onBottomViewFrameChanged = onBottomViewFrameChanged
        self.onTextSend = onTextSend
        self.onAudioSend = onAudioSend
        self.onTextDidChange = onTextDidChange
    }

    func makeUIViewController(context: Context) -> ChatInputViewController {
        return ChatInputViewController(
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
