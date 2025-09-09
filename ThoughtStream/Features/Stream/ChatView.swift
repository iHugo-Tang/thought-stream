import SwiftUI
import LucideIcons
import SwiftUIIntrospect

struct ChatView: View {
    @ObservedObject var chatViewModel = ChatViewModel()
    
    let data = Array(1...20)
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(data, id: \.self) { i in
                    if i % 2 == 0 {
                        MessageBubble(
                            text: "Congratulations!",
                            isFromUser: true
                        )
                        .id(i)
                    } else {
                        MessageBubble(
                            text: "Thank you, I appreciate it;) btw, I'm hosting a party tonight, do come over!",
                            isFromUser: false
                        )
                        .id(i)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)) { _ in
                withAnimation {
                    proxy.scrollTo(data.last!, anchor: .bottom)
                }
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.interactively)
        .chatInput(chatViewModel: chatViewModel)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.thoughtStream.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar { navigationBar }
    }
}

struct MessageBubble: View {
    let text: String
    let isFromUser: Bool
    var backgroundColor: Color {
        isFromUser ? Color.thoughtStream.theme.green600 : Color.thoughtStream.neutral.gray200
    }
    
    var body: some View {
        HStack {
            if isFromUser {
                Spacer(minLength: 50)
            }
            
            Text(text)
                .appFont(size: .base, weight: .regular)
                .padding()
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
            Text("Free")
                .appFont(size: .xs, weight: .medium)
                .appCapsuleTag(
                    background: .thoughtStream.theme.green100,
                    foreground: .thoughtStream.theme.green700,
                    horizontal: 8,
                    vertical: 4
                )
        }
    }
}

#Preview {
    ChatView()
}
