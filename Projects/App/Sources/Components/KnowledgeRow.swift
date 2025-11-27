import SwiftUI

struct KnowledgeRow: View {
    let item: KnowledgeItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.title)
                    .font(FontSize.body.font())
                    .foregroundColor(.asset.textPrimary)
                Spacer()
                
                Image(systemName: item.isSelected ? "star.fill" : "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(
                        item.isSelected
                        ? .asset.textAccentInteractive
                        : .asset.iconPrimary
                    )
            }
            
            HStack {
                Text(item.desc)
                    .font(FontSize.caption.font())
                    .foregroundColor(.asset.textSecondary)
                    
                Spacer()
                
                
                Text(item.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(FontSize.caption.font())
                    .foregroundColor(.asset.textSecondary)
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
        Color.asset.bgPrimary.edgesIgnoringSafeArea(.all)
        KnowledgeRow(
            item: KnowledgeItem(
                title: "Idiom: Break the ice",
                desc: "To initiate a conversation in a social setting to make people feel more comfortable.",
                tags: [
                    ("English", .asset.tagGreen),
                    ("Idiom", .asset.tagPurple),
                    ("Conversation", .asset.tagOrange)
                ],
                createdAt: Date(),
                isSelected: true
            )
        )
    }
}
