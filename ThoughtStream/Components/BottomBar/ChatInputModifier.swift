import SwiftUI

extension View {
    func chatInput<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        modifier(Modifier(barContent: content))
    }
}

struct Modifier<BarContent : View>: ViewModifier {
    
    @ViewBuilder
    let barContent: BarContent
    
    @State
    private var height: CGFloat?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            content
                .safeAreaPadding(.bottom, height)
            UIKitViewControllerWrapper { bottomViewFrame in
                height = bottomViewFrame.height
            }
        }
        .ignoresSafeArea(.all, edges: .bottom) // this is for SwiftUI layout interactive dissmissing animation bug
    }
}

struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    let onBottomViewFrameChanged: ((CGRect) -> Void)?
    
    func makeUIViewController(context: Context) -> ChatInputViewController {
        return ChatInputViewController(onBottomViewFrameChanged: onBottomViewFrameChanged)
    }

    func updateUIViewController(_ uiViewController: ChatInputViewController, context: Context) {
        // 这里可以处理状态更新
    }
}
