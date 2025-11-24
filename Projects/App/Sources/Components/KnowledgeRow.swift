import SwiftUI

struct KnowledgeRow: View {
    let item: KnowledgeItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.title)
                    .font(FontSize.body.font())
                    .foregroundColor(ThoughtStreamAsset.Colors.textPrimary.swiftUIColor)
                Spacer()
                
                Image(systemName: item.isSelected ? "star.fill" : "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(
                        item.isSelected
                        ? ThoughtStreamAsset.Colors.textAccentInteractive.swiftUIColor
                        : ThoughtStreamAsset.Colors.iconPrimary.swiftUIColor
                    )
            }
            
            HStack {
                Text(item.desc)
                    .font(FontSize.caption.font())
                    .foregroundColor(ThoughtStreamAsset.Colors.textSecondary.swiftUIColor)
                    
                Spacer()
                
                
                Text(item.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(FontSize.caption.font())
                    .foregroundColor(ThoughtStreamAsset.Colors.textSecondary.swiftUIColor)
                    .frame(width: 90, alignment: .trailing)
            }

            HStack {
                ForEach(item.tags, id: \.0) { tag in
                    Text("#\(tag.0)")
                        .font(FontSize.caption.font())
                        .foregroundColor(tag.1)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor.edgesIgnoringSafeArea(.all)
        KnowledgeRow(
            item: KnowledgeItem(
                title: "Idiom: Break the ice",
                desc: "To initiate a conversation in a social setting to make people feel more comfortable.",
                tags: [
                    ("English", ThoughtStreamAsset.Colors.tagGreen.swiftUIColor),
                    ("Idiom", ThoughtStreamAsset.Colors.tagPurple.swiftUIColor),
                    ("Conversation", ThoughtStreamAsset.Colors.tagOrange.swiftUIColor)
                ],
                createdAt: Date(),
                isSelected: true
            )
        )
    }
}
