import SwiftUI

struct HistoryView: View {
    @State private var searchText = ""
    @State private var selectedSegment: Segment = .all
    
    let tags = ["Business", "Conversation", "Vocabulary"]
    
    enum Segment: String, CaseIterable {
        case all = "All History"
        case favorites = "Favorites"
    }

    var body: some View {
        List {
            search
                .listRowBackground(ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor)
                .listRowSeparator(.hidden)
            segment
                .listRowBackground(ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor)
                .listRowSeparator(.hidden)
            filter
                .listRowBackground(ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor)
            itemList
                .listRowBackground(ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor)
    }
    
    var search: some View {
        TextField("Search", text: $searchText, prompt: Text("Search your knowledge base").foregroundColor(.gray))
            .foregroundColor(ThoughtStreamAsset.Colors.textPrimary.swiftUIColor)
            .padding()
            .background(ThoughtStreamAsset.Colors.bgSecondary.swiftUIColor)
            .cornerRadius(CornerSize.medium)
    }
    
    var segment: some View {
        Picker(selection: $selectedSegment, label: Text("Picker")) {
            ForEach (Segment.allCases, id: \.self) { segment in
                Text(segment.rawValue).tag(segment)
            }
        }
        .pickerStyle(.segmented)

    }
    
    var filter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                IconRoundButton(
                    icon: "line.horizontal.3.decrease",
                    title: "Filters",
                    isActive: .constant(true)
                )
                .allowsHitTesting(false)
                
                ForEach(tags, id: \.self) {
                    IconRoundButton(
                        title: "#\($0)",
                        isActive: .constant(false)
                    )
                }
            }
        }
    }
    
    var itemList: some View {
        ForEach(1..<10, id: \.self) { _ in
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
}

#Preview {
    NavigationStack {
        HistoryView()
            .navigationTitle("Knowledge Hub")
            .navigationBarTitleDisplayMode(.large)
    }
}

