import SwiftUI

struct CommandCardSection: Identifiable {
    let id = UUID()
    let title: String
    let content: [String]
    let contentBackground: Color
}

struct CommandCard: View {
    let title: String
    let sections: [CommandCardSection]
    let headerBackground: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.white)
                .padding(Edge.Set.horizontal)
                .padding(Edge.Set.vertical, 8)
                .frame(maxWidth: CGFloat.infinity, alignment: Alignment.leading)
                .background(headerBackground)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.system(size: 16, weight: .bold))
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(section.content, id: \.self) { line in
                                Text(line)
                                    .font(.system(size: 16, weight: .regular))
                            }
                        }
                        .padding()
                        .background(section.contentBackground)
                        .cornerRadius(8)
                    }
                }
            }.padding(Edge.Set.horizontal)
        }
        .padding(.bottom)
        .appCard()
    }
}

#Preview {
    CommandCard(
        title: "英语修改建议",
        sections: [
            CommandCardSection(
                title: "原句",
                content: [
                    "I've updated the rewriting API to remove the suggestions and reviews fields."
                ],
                contentBackground: Color.thoughtStream.neutral.gray100
            ),
            CommandCardSection(
                title: "修改",
                content: [
                    "I've updated the rewriting API to remove the suggestions and reviews fields."
                ],
                contentBackground: Color.thoughtStream.theme.green100
            ),
            CommandCardSection(
                title: "说明:",
                content: [
                    "1. After 'have', the verb should be in the past participle form. For 'update', it's 'updated'.",
                    "2. It's more natural to contract 'I have' to 'I've' in conversation.",
                    "3. Acronyms like 'API' should be capitalized."
                ],
                contentBackground: Color.thoughtStream.neutral.gray100
            )
        ],
        headerBackground: Color.thoughtStream.bg.indigo600
    )
}
