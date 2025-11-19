import SwiftUI

struct HomeView: View {
    private let cards: [StatisticsCardData] = [
        .init(
            title: "Expressions Mastered this Week",
            count: 12,
            change: "+2"
        ),
        .init(
            title: "Total Reports Generated",
            count: 8,
            change: "-5"
        )
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                StatisticsCardGrid(cards: cards)
                
                VStack(spacing: 16) {
                    LargeButton(title: "Start a New Record")
                    LargeButton(buttonType: .secondary, title: "Start Thinking Practice")
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    SectionTitleLabel(title: "Thought of the Day")
                    ThoughtTopicView(
                        title: "The limits of my language mean the limits of my world.",
                        source: "Ludwig Wittgenstein",
                        subtitle: "A daily quote to inspire your English thinking journey."
                    )
                }
            }
            .padding(.horizontal, 24)
        }
        .background(ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
    }
}
