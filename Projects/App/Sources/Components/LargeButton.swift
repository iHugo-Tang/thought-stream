import SwiftUI

struct LargeButton: View {
    let buttonType: Types
    let title: String
    var action: () -> Void
    
    enum Types {
        case primary
        case secondary
    }
    
    init(buttonType: Types = .primary, title: String, action: @escaping () -> Void = {}) {
        self.buttonType = buttonType
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
        }
        .buttonStyle(PrimaryCTAButtonStyle(buttonType: buttonType))
        .accessibilityLabel(title)
    }
}

private struct PrimaryCTAButtonStyle: ButtonStyle {
    let buttonType: LargeButton.Types
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FontSize.button.font())
            .foregroundStyle(Color.white)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerSize.medium, style: .continuous)
                    .fill(
                        buttonType == .primary
                            ? ThoughtStreamAsset.Colors.btnPrimary.swiftUIColor
                            : ThoughtStreamAsset.Colors.btnSecondary.swiftUIColor
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: CornerSize.medium, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor.ignoresSafeArea()
        VStack(spacing: 24) {
            LargeButton(title: "Start a New Record")
                .padding(.horizontal, 24)
            
            LargeButton(buttonType: .secondary, title: "Start a New Record")
                .padding(.horizontal, 24)
        }
    }
}
