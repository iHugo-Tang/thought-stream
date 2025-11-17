import SwiftUI

struct SectionTitleLabel: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(FontSize.headline.font())
            .foregroundColor(ThoughtStreamAsset.Colors.textPrimary.swiftUIColor)
            .padding(.bottom, 16)
    }
}

#Preview {
    ZStack {
        ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor
        SectionTitleLabel(title: "Thought of the Day")
    }
}
