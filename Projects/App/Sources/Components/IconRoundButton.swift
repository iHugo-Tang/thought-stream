import SwiftUI

struct IconRoundButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    @Binding var isActive: Bool
    
    init(
        icon: String = "",
        title: String = "",
        isActive: Binding<Bool> = .constant(false),
        action: @escaping () -> Void = {}
    ) {
        self.icon = icon
        self.title = title
        _isActive = isActive
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .fontWeight(.medium)
                }
                
                if !title.isEmpty {
                    Text(title)
                        .font(FontSize.caption.font())
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isActive
                ? ThoughtStreamAsset.Colors.btnPrimary.swiftUIColor
                : ThoughtStreamAsset.Colors.btnTertiary.swiftUIColor
            )
            .clipShape(Capsule())
        }
    }
}

#Preview {
    ZStack {
        Color("BgPrimary")
            .ignoresSafeArea()
        IconRoundButton(
            icon: "line.horizontal.3.decrease",
            title: "Filters",
            isActive: .constant(true)
        )
    }
}
