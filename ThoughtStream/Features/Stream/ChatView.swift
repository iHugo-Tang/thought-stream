import SwiftUI
import LucideIcons
import SwiftUIIntrospect
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chatViewModel: ChatViewModel
    @State private var showDeleteAlert: Bool = false

    init(conversation: ConversationEntity? = nil) {
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(conversation: conversation))
    }

    // Alternative simpler init for new conversations
    init() {
        _chatViewModel = StateObject(wrappedValue: ChatViewModel())
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(chatViewModel.messages) { message in
                    if let analysis = message.analysis {
                        IdiomaticResultView(analysis: analysis)
                    } else {
                        MessageBubble(
                            text: message.text,
                            isFromUser: message.sendByYou,
                            isCommand: message.isCommand
                        )
                    }
                }
                if let status = chatViewModel.systemStatus {
                    SystemStatusRow(status: status) {
                        chatViewModel.retryCurrentSystemTask()
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .onChange(of: chatViewModel.messages.count) { _ in
                withAnimation {
                    if let lastId = chatViewModel.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)) { _ in
                withAnimation {
                    if let lastId = chatViewModel.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.interactively)
        .chatInput(
            onTextSend: { chatViewModel.handleTextSend($0, textView: $1) },
            onAudioSend: { chatViewModel.handleAudioSend() },
            onTextDidChange: { chatViewModel.handleTextDidChange($0, textView: $1) },
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.thoughtStream.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar { navigationBar }
        // Toast overlay for transient errors
        .overlay(alignment: .top) {
            if let msg = chatViewModel.errorMessage {
                ToastView(text: msg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation { chatViewModel.errorMessage = nil }
                        }
                    }
                    .padding(.top, 8)
            }
        }
        .alert("Delete this conversation?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if chatViewModel.deleteConversation() {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove all messages.")
        }
        .onAppear {
            chatViewModel.bind(modelContext: modelContext)
        }
    }
}

struct MessageBubble: View {
    let text: String
    let isFromUser: Bool
    let isCommand: Bool
    var backgroundColor: Color {
        if isCommand { return Color.thoughtStream.bg.indigo600 }
        return isFromUser ? Color.thoughtStream.theme.green600 : Color.thoughtStream.neutral.gray200
    }
    
    var body: some View {
        HStack {
            if isFromUser {
                Spacer(minLength: 50)
            }
            
            Text(text)
                .appFont(size: .base, weight: .regular)
                .padding(.all, 10)
                .padding(.leading, !isFromUser ? 8 : 0)
                .padding(.trailing, isFromUser ? 8 : 0)
                .foregroundColor(isFromUser ? .white : .black)
                .background(
                    BubbleShape()
                        .fill(backgroundColor)
                        .stroke(backgroundColor)
                        .rotation3DEffect(isFromUser ? .degrees(0) : .degrees(180), axis: (x: 0, y: 1, z: 0))
                )
            
            if !isFromUser {
                Spacer(minLength: 50)
            }
        }
        .listRowSeparator(.hidden)
    }
}

private struct SystemStatusRow: View {
    let status: ChatViewModel.SystemStatus
    var onRetry: () -> Void

    var body: some View {
        HStack {
            // Left-aligned like assistant/system
            HStack {
                Text(contentText)
                    .appFont(size: .xs)
                    .padding(.leading, 8)
                if case .loading = status {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                if case .error = status {
                    Button(action: onRetry) {
                        Text("Retry")
                            .appFont(size: .xs, weight: .medium)
                    }
                    .buttonStyle(.bordered)
                    .tint(.thoughtStream.theme.green600)
                }
            }
                .padding(.all, 10)
                .foregroundColor(.black)
                .background(
                    BubbleShape()
                        .fill(Color.thoughtStream.neutral.gray200)
                        .stroke(Color.thoughtStream.neutral.gray200)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                )
            Spacer(minLength: 50)
        }
        .listRowSeparator(.hidden)
    }

    private var contentText: String {
        switch status {
        case .loading(let msg):
            return msg
        case .error(let msg):
            return msg
        }
    }
}

private struct ToastView: View {
    let text: String
    var body: some View {
        Text(text)
            .appFont(size: .xs)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.8))
            .cornerRadius(8)
            .shadow(radius: 4)
    }
}

struct BubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = Path { path in
            let cornerRadius: Double = 10
            let tailWidth: Double = 8
            let tailHeight = cornerRadius
            let bubbleWidth = rect.width - tailWidth
            
            // these required a little geometry to find the midpoint of an arc,
            // the formula also requires that the angle be in radians (not degrees) which is why
            // we are using pi / 4 (radians) in the forumula below (which is equivalent to 45 degrees)
            let tailEndpointX = (bubbleWidth - cornerRadius) + cornerRadius * cos(.pi / 4)
            let tailEndpointY = (rect.height - cornerRadius) + cornerRadius * sin(.pi / 4)
            
            path.move(to: CGPoint(x: cornerRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: bubbleWidth - cornerRadius, y: rect.minY))
            
            // Top-right corner
            path.addArc(
                center: CGPoint(x: bubbleWidth - cornerRadius, y: cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: -90),
                endAngle: Angle(degrees: 0),
                clockwise: false
            )
            
            path.addLine(to: CGPoint(x: bubbleWidth, y: cornerRadius))
            path.addLine(to: CGPoint(x: bubbleWidth, y: rect.height - cornerRadius))
            
            // Tail
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: rect.height),
                control: CGPoint(x: bubbleWidth, y: rect.height - (tailHeight / 2))
            )
            path.addQuadCurve(
                to: CGPoint(x: tailEndpointX, y: tailEndpointY),
                control: CGPoint(x: bubbleWidth, y: rect.height)
            )
            
            // Bottom-right corner
            path.addArc(
                center: CGPoint(x: bubbleWidth - cornerRadius, y: rect.height - cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: 45),
                endAngle: Angle(degrees: 90),
                clockwise: false
            )
            
            path.addLine(to: CGPoint(x: bubbleWidth - cornerRadius - tailWidth, y: rect.height))
            path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.height))
            
            // Bottom-left corner
            path.addArc(
                center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false
            )
            
            path.addLine(to: CGPoint(x: rect.minX, y: rect.height - cornerRadius))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
            
            // Top-left corner
            path.addArc(
                center: CGPoint(x: cornerRadius, y: cornerRadius),
                radius: cornerRadius,
                startAngle: Angle(degrees: 180),
                endAngle: Angle(degrees: 270),
                clockwise: false
            )
            
            path.closeSubpath()
        }
        
        return path
    }
}

private extension ChatView {
    @ToolbarContentBuilder
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 8) {
                Image(uiImage: Lucide.pen)
                    .renderingMode(.template)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.thoughtStream.neutral.gray800)
                Text("Thought")
                    .appFont(size: .lg, weight: .bold)
                    .foregroundColor(.thoughtStream.neutral.gray800)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ShareLink(item: makeExportFileURL()) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.thoughtStream.neutral.gray800)
            }
        }
    }
}

private extension ChatView {
    func makeExportFileURL() -> URL {
        let text = chatViewModel.exportText()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd-HHmmss"
        let timestamp = df.string(from: Date())
        let filename = "Conversation-\(timestamp).txt"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            // Best-effort: if write fails, still return a path to avoid crashing
        }
        return url
    }
}

#Preview {
    ChatView()
    SystemStatusRow(status: ChatViewModel.SystemStatus.loading("loading")) {}
    SystemStatusRow(status: ChatViewModel.SystemStatus.error("error")) {}
    MessageBubble(text: "1", isFromUser: true, isCommand: false)
    MessageBubble(text: "2", isFromUser: false, isCommand: false)
    IdiomaticResultView(
        title: "英语修改建议",
        original: [
            "I've updated the rewriting API to remove the suggestions and reviews fields."
        ],
        revision: [
            "I've updated the rewriting API to remove the suggestions and reviews fields."
        ],
        explanations: [
            "1. After 'have', the verb should be in the past participle form. For 'update', it's 'updated'.",
            "2. It's more natural to contract 'I have' to 'I've' in conversation.",
            "3. Acronyms like 'API' should be capitalized."
        ]
    )
    MessageBubble(text: CommandRegistry.slashPrefix + CommandRegistry.displayName(for: "idiomatic_english"), isFromUser: true, isCommand: true)
}
