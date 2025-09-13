import SwiftUI
import SwiftData
import LucideIcons

struct StreamView: View {
    @Environment(\.tabBarHeight) private var tabBarHeight
    @State private var searchText: String = ""
    @Query(
        sort: [SortDescriptor(\ConversationEntity.updatedAt, order: .reverse)],
        animation: .default
    ) private var conversations: [ConversationEntity]
    

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // searchBar
                if conversations.isEmpty {
                    EmptyStateView(message: "Start your first conversation")
                } else {
                    todaySection
                    yesterdaySection
                    olderSection
                }
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
                HStack(spacing: 12) {
                    NavigationLink(destination: ChatView().hideTabBarOnPush()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private extension StreamView {
    // MARK: - Grouped Conversations
    var todayConversations: [ConversationEntity] {
        conversations.filter { Calendar.current.isDateInToday($0.updatedAt) }
    }

    var yesterdayConversations: [ConversationEntity] {
        conversations.filter { Calendar.current.isDateInYesterday($0.updatedAt) }
    }

    var olderDateConversations: [ConversationEntity] {
        conversations.filter { !Calendar.current.isDateInToday($0.updatedAt) && !Calendar.current.isDateInYesterday($0.updatedAt) }
    }

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

    @ViewBuilder
    var todaySection: some View {
        if !todayConversations.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Today")
                    .appFont(size: .xs, weight: .medium)
                    .foregroundColor(.thoughtStream.neutral.gray700)

                VStack(spacing: 12) {
                    ForEach(todayConversations, id: \.id) { conversation in
                        NavigationLink(destination: ChatView(conversation: conversation).hideTabBarOnPush()) {
                            StreamCard(conversation: conversation)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    @ViewBuilder
    var yesterdaySection: some View {
        if !yesterdayConversations.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Yesterday")
                    .appFont(size: .xs, weight: .medium)
                    .foregroundColor(.thoughtStream.neutral.gray700)

                VStack(spacing: 12) {
                    ForEach(yesterdayConversations, id: \.id) { conversation in
                        NavigationLink(destination: ChatView(conversation: conversation).hideTabBarOnPush()) {
                            StreamCard(conversation: conversation)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    @ViewBuilder
    var olderSection: some View {
        let olderConversations = olderDateConversations

        if !olderConversations.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Older")
                    .appFont(size: .xs, weight: .medium)
                    .foregroundColor(.thoughtStream.neutral.gray700)

                VStack(spacing: 12) {
                    ForEach(olderConversations.prefix(10), id: \.id) { conversation in
                        NavigationLink(destination: ChatView(conversation: conversation).hideTabBarOnPush()) {
                            StreamCard(conversation: conversation)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

// MARK: - Components
private struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(uiImage: Lucide.messageCircle)
                .renderingMode(.template)
                .foregroundColor(.thoughtStream.neutral.gray300)
                .font(.system(size: 48))
                
            Text(message)
                .appFont(size: .sm)
                .foregroundColor(.thoughtStream.neutral.gray500)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .appCard(cornerRadius: 12)
    }
}

private struct StreamCard: View {
    let conversation: ConversationEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(conversation.displayTitle)
                .appFont(size: .sm, weight: .medium)
                .foregroundColor(.thoughtStream.neutral.gray800)

            Text(conversation.displayBodyText)
                .appFont(size: .sm)
                .foregroundColor(.thoughtStream.neutral.gray600)
                .lineLimit(4)

            // Tags
            if !conversation.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(conversation.tags, id: \.self) { tag in
                            TagChip(text: tag)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            // Footer
            HStack {
                Text("🕓 \(conversation.formattedDateText)")
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
