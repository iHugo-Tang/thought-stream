import SwiftUI

struct IdiomaticResultView: View {
    let title: String
    let original: [String]
    let revision: [String]
    let explanations: [String]

    var body: some View {
        CommandCard(
            title: title,
            sections: [
                CommandCardSection(
                    title: "原句",
                    content: original,
                    contentBackground: Color.thoughtStream.neutral.gray100
                ),
                CommandCardSection(
                    title: "修改",
                    content: revision,
                    contentBackground: Color.thoughtStream.theme.green100
                ),
                CommandCardSection(
                    title: "说明:",
                    content: explanations,
                    contentBackground: Color.thoughtStream.neutral.gray100
                )
            ],
            headerBackground: Color.thoughtStream.bg.indigo600
        )
    }
}

extension IdiomaticResultView {
    init(analysis: AnalysisData) {
        let title = "英语修改建议"
        let originals = analysis.revisions.map { $0.original }
        let revisions = analysis.revisions.map { $0.good_to_say }
        let explanations = analysis.revisions.flatMap { $0.explanations }
        self.init(title: title, original: originals, revision: revisions, explanations: explanations)
    }
}

#Preview {
    IdiomaticResultView(
        title: "英语修改建议",
        original: [
            "I've updated the rewriting API to remove the suggestions and reviews fields."
        ],
        revision: [
            "I've updated the rewriting API to remove the suggestions and reviews fields."
        ],
        explanations: [
            "1. After 'have', the verb should be in the past participle form. For 'update', it's 'updated'.",
            "2. It's more natural to contract 'I have' to 'I've' in conversation.",
            "3. Acronyms like 'API' should be capitalized."
        ]
    )
}
