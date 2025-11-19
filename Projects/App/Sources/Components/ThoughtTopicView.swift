import SwiftUI

struct ThoughtTopicView: View {
    let title: String
    let source: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image("placeholder")
                .resizable()
                .aspectRatio(4.0 / 3, contentMode: .fit)
            
            Text(title)
                .font(FontSize.headline.font())
                .foregroundColor(ThoughtStreamAsset.Colors.textPrimary.swiftUIColor)
            Text(source)
                .font(FontSize.bodyEmphasis.font())
                .foregroundColor(ThoughtStreamAsset.Colors.textSecondary.swiftUIColor)
            Text(subtitle)
                .font(FontSize.caption.font())
                .foregroundColor(ThoughtStreamAsset.Colors.textSecondary.swiftUIColor)
            HStack {
                LargeButton(buttonType: .primary, title: "Share")
                    .frame(width: 120)
                Button {
                } label: {
                    Image(systemName: "heart")
                }
                .frame(width: 48)
                .accentColor(ThoughtStreamAsset.Colors.iconPrimary.swiftUIColor)
            }
        }
    }
}

#Preview {
    ZStack {
        ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor.edgesIgnoringSafeArea(.all)
        ThoughtTopicView(
            title: "The limits of my language mean the limits of my world.",
            source: "Ludwig Wittgenstein",
            subtitle: "A daily quote to inspire your English thinking journey."
        )
    }
}
