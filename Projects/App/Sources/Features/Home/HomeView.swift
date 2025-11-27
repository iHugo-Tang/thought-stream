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
        ),
    ]
    @State private var largeHeaderOpacity: CGFloat = 1
    @State private var compactHeaderOpacity: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // 1. 将监测器独立出来，包裹在无间距的 VStack 中以避免布局干扰
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 0)  // 占据 0 高度，不可见但存在
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.frame(in: .named("scroll")).minY
                        } action: { newValue in
                            self.scrollOffset = newValue
                            updateHeaderOpacities()
                        }

                    LargeNavBarView()
                        .opacity(largeHeaderOpacity)
                }

                ContentArea
            }
        }
        .coordinateSpace(name: "scroll")
        .background(Color.asset.bgPrimary)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Good morning, Alex!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(compactHeaderOpacity)
            }
            if compactHeaderOpacity > 0 {
                ToolbarItem(placement: .topBarLeading) {
                    CircleView(size: 32, iconSize: 14)
                        .opacity(compactHeaderOpacity)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.white)
                        .opacity(compactHeaderOpacity)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var ContentArea: some View {
        Group {
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
        .padding(.horizontal)
    }

    private func updateHeaderOpacities() {
        let threshold: CGFloat = 80
        largeHeaderOpacity = min(1, max((threshold + scrollOffset) / threshold, 0))
        compactHeaderOpacity = 1 - largeHeaderOpacity
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
    }
}
