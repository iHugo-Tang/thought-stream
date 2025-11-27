import SwiftUI

struct LargeButton: View {
    let buttonType: Types
    let title: String
    var action: () -> Void
    
    enum Types {
        case primary
        case secondary
        case destructive
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
    
    var bgColor: Color {
        switch buttonType {
            case .primary:
            return Color.asset.btnPrimary
        case .secondary:
            return Color.asset.btnSecondary
        case .destructive:
            return Color.asset.btnSecondary
        }
    }
    
    var textColor: Color {
        switch buttonType {
        case .primary:
            return Color.white
        case .secondary:
            return Color.white
        case .destructive:
            return Color.asset.btnWarn
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FontSize.button.font())
            .foregroundStyle(textColor)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerSize.medium, style: .continuous)
                    .fill(bgColor)
            )
            .contentShape(RoundedRectangle(cornerRadius: CornerSize.medium, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.asset.bgPrimary.ignoresSafeArea()
        VStack(spacing: 24) {
            LargeButton(title: "Start a New Record")
                .padding(.horizontal, 24)
            
            LargeButton(buttonType: .secondary, title: "Start a New Record")
                .padding(.horizontal, 24)
            
            LargeButton(buttonType: .destructive, title: "Log Out")
                .padding(.horizontal, 24)
        }
    }
}
