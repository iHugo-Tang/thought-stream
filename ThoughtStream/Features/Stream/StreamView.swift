import SwiftUI
import LucideIcons

struct StreamView: View {
    @Environment(\.tabBarHeight) private var tabBarHeight
    @State private var searchText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                searchBar
                yesterdaySection
                olderSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, tabBarHeight + 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.thoughtStream.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(uiImage: Lucide.pen)
                        .renderingMode(.template)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.thoughtStream.neutral.gray800)
                    Text("My Streams")
                        .appFont(size: .lg, weight: .bold)
                        .foregroundColor(.thoughtStream.neutral.gray800)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

// MARK: - Subviews
private extension StreamView {
    var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(uiImage: Lucide.search)
                    .renderingMode(.template)
                    .foregroundColor(.thoughtStream.neutral.gray400)
                TextField("Search your thoughts...", text: $searchText)
                    .appFont(size: .base)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.thoughtStream.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.thoughtStream.neutral.gray200, lineWidth: 1)
            )
            .cornerRadius(8)

            Button(action: {}) {
                Image(uiImage: Lucide.slidersHorizontal)
                    .renderingMode(.template)
                    .foregroundColor(.thoughtStream.neutral.gray700)
            }
            .frame(width: 44, height: 50)
            .background(Color.thoughtStream.neutral.gray100)
            .cornerRadius(8)
        }
    }

    var yesterdaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Yesterday")
                .appFont(size: .xs, weight: .medium)
                .foregroundColor(.thoughtStream.neutral.gray700)

            StreamCard(
                title: "The highlight of my weekend so far was...",
                bodyText: "I think the best part was the quiet morning I had. I woke up without an alarm clock, made a perfect cup of coffee, and just sat by the window reading a book. It was a simple moment but it felt so...",
                tags: ["personal", "weekend", "reflection"],
                dateText: "August 30, 2025 - 5:15 PM"
            )
        }
    }

    var olderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Older")
                .appFont(size: .xs, weight: .medium)
                .foregroundColor(.thoughtStream.neutral.gray700)

            VStack(spacing: 12) {
                StreamCard(
                    title: "My thoughts on the new project at work",
                    bodyText: "The initial requirements seem a bit ambiguous, especially regarding the performance metrics. I should probably schedule a meeting with the PM to clarify these points next week. Writing this down helps me organize...",
                    tags: ["work", "project", "productivity"],
                    dateText: "August 29, 2025 - 9:22 AM"
                )

                StreamCard(
                    title: "Practicing describing my favorite food",
                    bodyText: "My favorite food has to be ramen. I love the rich and savory broth, the perfectly chewy noodles, and the soft-boiled egg on top. Every slurp is a comforting experience, especially on a cold day...",
                    tags: ["learning", "food", "practice"],
                    dateText: "August 27, 2025 - 8:04 PM"
                )
            }
        }
    }
}

// MARK: - Components
private struct StreamCard: View {
    let title: String
    let bodyText: String
    let tags: [String]
    let dateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .appFont(size: .sm, weight: .medium)
                .foregroundColor(.thoughtStream.neutral.gray800)

            Text(bodyText)
                .appFont(size: .sm)
                .foregroundColor(.thoughtStream.neutral.gray600)
                .lineLimit(4)

            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagChip(text: tag)
                    }
                }
                .padding(.vertical, 2)
            }

            // Footer
            HStack {
                Text("🕓 \(dateText)")
                    .appFont(size: .xs)
                    .foregroundColor(.thoughtStream.neutral.gray500)
                Spacer()
                HStack(spacing: 4) {
                    StreamStatusView(status: .favorite)
                    StreamStatusView(status: .voice)
                    StreamStatusView(status: .feedback)
                }
            }
        }
        .padding(20)
        .appCard(cornerRadius: 12)
    }
}

private struct TagChip: View {
    let text: String
    var background: Color = .thoughtStream.theme.green100
    var foreground: Color = .thoughtStream.theme.green700
    var showHash: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            if showHash { Text("#") }
            Text(text)
        }
        .appFont(size: .xs)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(background)
        .foregroundColor(foreground)
        .cornerRadius(9999)
    }
}

private struct StreamStatusView: View {
    let status: StreamStatus
    
    enum StreamStatus {
        case feedback
        case voice
        case favorite
    }
    
    var body: some View {
        switch status {
        case .feedback:
            Image(uiImage: Lucide.sparkles)
                .renderingMode(.template)
                .foregroundColor(.thoughtStream.theme.green600)
                .frame(width: 16, height: 16)
        case .voice:
            Image(uiImage: Lucide.mic)
                .renderingMode(.template)
                .foregroundColor(.thoughtStream.theme.green600)
                .frame(width: 16, height: 16)
        case .favorite:
            Image(uiImage: Lucide.heart)
                .renderingMode(.template)
                .foregroundColor(.thoughtStream.functional.red500)
                .frame(width: 16, height: 16)
        }
    }
}

struct StreamView_Previews: PreviewProvider {
    static var previews: some View {
//        StreamView()
        MainTabView()
    }
}

struct StreamStatusView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StreamStatusView(status: .feedback)
            StreamStatusView(status: .voice)
            StreamStatusView(status: .favorite)
        }
    }
}
