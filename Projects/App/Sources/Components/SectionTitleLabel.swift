import SwiftUI

struct SectionTitleLabel: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(FontSize.headline.font())
            .foregroundColor(.asset.textPrimary)
            .padding(.bottom, 16)
    }
}

#Preview {
    ZStack {
        Color.asset.bgPrimary
        SectionTitleLabel(title: "Thought of the Day")
    }
}
