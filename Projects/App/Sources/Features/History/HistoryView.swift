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
                .listRowBackground(Color.asset.bgPrimary)
                .listRowSeparator(.hidden)
            segment
                .listRowBackground(Color.asset.bgPrimary)
                .listRowSeparator(.hidden)
            filter
                .listRowBackground(Color.asset.bgPrimary)
            itemList
                .listRowBackground(Color.asset.bgPrimary)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.asset.bgPrimary)
    }
    
    var search: some View {
        TextField("Search", text: $searchText, prompt: Text("Search your knowledge base").foregroundColor(.gray))
            .foregroundColor(.asset.textPrimary)
            .padding()
            .background(Color.asset.bgSecondary)
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
}

#Preview {
    NavigationStack {
        HistoryView()
            .navigationTitle("Knowledge Hub")
            .navigationBarTitleDisplayMode(.large)
    }
}

