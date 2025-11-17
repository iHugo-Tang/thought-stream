import SwiftUI

struct StatisticsCard: View {
    let title: String
    let count: Int
    let change: String
    
    @Binding var measuredHeight: CGFloat?
    var enforcedHeight: CGFloat?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .lineLimit(3)
                .font(FontSize.body.font())
                .foregroundColor(ThoughtStreamAsset.Colors.textPrimary.swiftUIColor)
            Text("\(count)")
                .font(FontSize.display.font())
                .foregroundColor(ThoughtStreamAsset.Colors.textPrimary.swiftUIColor)
                .padding(.top, 8)
            Text("\(change)% vs last week ")
                .lineLimit(2)
                .font(FontSize.bodyEmphasis.font())
                .foregroundColor(ThoughtStreamAsset.Colors.textAccentPositive.swiftUIColor)
                .padding(.top, 8)
        }
        .padding(24)
        .background(ThoughtStreamAsset.Colors.bgSecondary.swiftUIColor)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            let newHeight = size.height
            guard measuredHeight != newHeight else { return }
            measuredHeight = newHeight
        }
        .frame(height: enforcedHeight)
    }
}

struct StatisticsCardData: Identifiable, Equatable {
    let id: UUID
    let title: String
    let count: Int
    let change: String
    
    init(
        id: UUID = UUID(),
        title: String,
        count: Int,
        change: String
    ) {
        self.id = id
        self.title = title
        self.count = count
        self.change = change
    }
}

struct StatisticsCardGrid: View {
    let cards: [StatisticsCardData]
    
    @State private var cardHeights: [StatisticsCardData.ID: CGFloat] = [:]
    @State private var sharedHeight: CGFloat?
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(cards) { card in
                StatisticsCard(
                    title: card.title,
                    count: card.count,
                    change: card.change,
                    measuredHeight: bindingForCardHeight(card.id),
                    enforcedHeight: sharedHeight
                )
                .frame(maxWidth: .infinity)
                .background(ThoughtStreamAsset.Colors.bgSecondary.swiftUIColor)
                .cornerRadius(CornerSize.medium)
            }
        }
        .onChange(of: cards.map(\.id)) { _, ids in
            cardHeights = cardHeights.filter { ids.contains($0.key) }
            sharedHeight = cardHeights.values.max()
        }
    }
    
    private func bindingForCardHeight(_ id: StatisticsCardData.ID) -> Binding<CGFloat?> {
        Binding(
            get: { cardHeights[id] },
            set: { newValue in
                if let newValue {
                    cardHeights[id] = newValue
                } else {
                    cardHeights[id] = nil
                }
                sharedHeight = cardHeights.values.max()
            }
        )
    }
}

private struct StatisticsCardPreviewContent: View {
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
        .init(
            title: "New Ideas Captured",
            count: 21,
            change: "+4"
        ),
        .init(
            title: "Sessions Completed",
            count: 15,
            change: "+1"
        )
    ]
    
    var body: some View {
        VStack {
            Spacer()
            StatisticsCardGrid(cards: cards)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview() {
    StatisticsCardPreviewContent()
}
