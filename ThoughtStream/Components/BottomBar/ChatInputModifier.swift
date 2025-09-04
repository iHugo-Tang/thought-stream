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
            UIKitViewControllerWrapper { contentRect, keyboardRect in
                height = contentRect.height + keyboardRect.height
            }
        }
        .ignoresSafeArea(.all, edges: .bottom) // this is for SwiftUI layout interactive dissmissing animation bug
    }
}

class ChatInputView: UIView {
    weak var textfield: UIKit.UITextView?
    
    override func hitTest(_ point: CGPoint, with event: UIKit.UIEvent?) -> UIKit.UIView? {
        guard let textfield = textfield else { return nil }
        
        let convertedPoint = textfield.convert(point, from: self)
        if textfield.bounds.contains(convertedPoint) {
            return textfield.hitTest(convertedPoint, with: event)
        }
        return nil
    }
}

class ChatInputViewController: UIViewController, UITextViewDelegate {
    var rowHeight : CGFloat = 14
    var baseHeight: CGFloat = 30
    var maxHeight: CGFloat = 30
    var heightConstraint: NSLayoutConstraint?
    var onUpdateBottom: ((CGRect, CGRect) -> Void)?
    
    let textfield: UITextView = {
        let myTxtView = UITextView()
        myTxtView.textColor = .lightGray
        myTxtView.text = "Type your thoughts here..."
        myTxtView.font = .systemFont(ofSize: 14)
        
        return myTxtView
    }()
    
    init(onUpdateBottom: ((CGRect, CGRect) -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.onUpdateBottom = onUpdateBottom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let bottomView = ChatInputView()
        bottomView.textfield = textfield
        self.view = bottomView
        bottomView.backgroundColor = .red.withAlphaComponent(0.5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textfield.delegate = self
        
        if let font = self.textfield.font {
            self.rowHeight = self.textfield.font!.lineHeight
            let verticalPadding = self.textfield.textContainerInset.top + self.textfield.textContainerInset.bottom
            // Height for a single line
            self.baseHeight = font.lineHeight + verticalPadding
            // Max height for 3 lines
            self.maxHeight = (font.lineHeight * 3) + verticalPadding
        }
        
        view.addSubview(self.textfield)
        self.textfield.translatesAutoresizingMaskIntoConstraints = false
        self.heightConstraint = self.textfield.heightAnchor.constraint(equalToConstant: baseHeight)
        NSLayoutConstraint.activate([
            self.textfield.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.textfield.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.textfield.bottomAnchor.constraint(equalTo: self.view.keyboardLayoutGuide.topAnchor),
            self.heightConstraint!
        ])
    }
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        if textfield.textColor == .lightGray && textfield.isFirstResponder {
            textfield.text = nil
            textfield.textColor = .black
        }
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        if textfield.text.isEmpty || textfield.text == "" {
            textfield.textColor = .lightGray
            textfield.text = "Type your thoughts here..."
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.contentSize.height)
        self.heightConstraint?.constant = min(textView.contentSize.height, 58)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.onUpdateBottom?(
            self.textfield.frame,
            self.view.keyboardLayoutGuide.layoutFrame
        )
    }
}

struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    let onUpdateBottom: ((CGRect, CGRect) -> Void)?
    
    func makeUIViewController(context: Context) -> ChatInputViewController {
        return ChatInputViewController(onUpdateBottom: onUpdateBottom)
    }

    func updateUIViewController(_ uiViewController: ChatInputViewController, context: Context) {
        // 这里可以处理状态更新
    }
}
