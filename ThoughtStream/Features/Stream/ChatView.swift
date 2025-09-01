import SwiftUI
import LucideIcons

struct ChatView: View {
    @Binding var text: String
    
    var body: some View {
        List {
            ForEach(0..<10) { _ in
                MessageBubble(
                    text: "Congratulations!",
                    isFromUser: true
                )
                
                MessageBubble(
                    text: "Thank you, I appreciate it;) btw, I'm hosting a party tonight, do come over!",
                    isFromUser: false
                )
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            HStack {
                TextField("What's on your mind?", text: $text)
                    .appFont(size: .base)
                    .frame(height: 36)
                    .padding(.horizontal)
                    .cornerRadius(10)
                
                Spacer()
                Image(uiImage: Lucide.mic)
                    .renderingMode(.template)
                    .foregroundColor(Color.thoughtStream.neutral.gray400)
                    .padding(.trailing)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.thoughtStream.neutral.gray300, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.vertical, 4)
            .background {
                Color.white.opacity(0.9)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
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

#Preview {
    ChatView(text: .constant(""))
}
