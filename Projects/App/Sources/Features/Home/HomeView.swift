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
            LazyVStack(spacing: 24) {
                StatisticsCardGrid(cards: cards)
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
