import SwiftUI

struct AchievementBadgeView: View {
    let title: String
    let image: Image
    let backgroundColor: Color
    let iconSize: CGSize
    var flipVertically: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 16, y: 8)
                
                image
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .frame(width: iconSize.width, height: iconSize.height)
            }
            .frame(width: 64, height: 64)
            
            Text(title)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .font(FontSize.caption.font())
                .foregroundColor(Color.asset.textPrimary)
        }
    }
}

#Preview {
    AchievementBadgeView(
        title: "Grammar Pro",
        image: ThoughtStreamAsset.Assets.achievementGrammar.swiftUIImage,
        backgroundColor: .asset.iconBgPrimary,
        iconSize: CGSize(width: 30, height: 36),
        flipVertically: true
    )
}
