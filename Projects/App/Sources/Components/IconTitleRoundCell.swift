import SwiftUI

struct IconTitleRoundCell: View {
    var body: some View {
        HStack {
            Image(systemName: "star")
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.asset.btnPrimary)
                .padding(.all, 12)

            VStack(alignment: .leading) {
                Text("Idea Generation")
                    .font(FontSize.caption.font())
                    .foregroundColor(.asset.textPrimary)
                Text("Practice brainstorming and forming opinions on a topic.")
                    .font(FontSize.footnote.font())
                    .foregroundColor(.asset.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ThoughtStreamAsset.Assets.cellArrow.swiftUIImage
        }
        .padding()
        .background(Color.asset.bgSecondary.cornerRadius(CornerSize.small))
    }
}

#Preview {
    IconTitleRoundCell()
}
