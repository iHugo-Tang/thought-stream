import SwiftUI
import LucideIcons

struct MainTabView: View {
    enum Tab: Hashable {
        case home
        case stream
        case vocab
        case review
        case profile
    }
    
    // 使用 init() 来自定义 TabBar 的全局外观
    init() {
        // 设置 TabBar 的背景颜色
        // UITabBar.appearance() 在 SwiftUI 中用于全局配置
        UITabBar.appearance().backgroundColor = UIColor(Color.thoughtStream.white)
        // 你也可以设置一个半透明的背景
        UITabBar.appearance().isHidden = true
    }

    @State private var selectedTab: Tab = .home
    private let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)

    struct TabItemData: Identifiable {
        let tab: Tab
        let title: String
        let image: UIImage
        var id: Tab { tab }
    }

    private var items: [TabItemData] {
        [
            .init(tab: .home, title: "主页", image: Lucide.house),
            .init(tab: .stream, title: "思绪", image: Lucide.pen),
            .init(tab: .vocab, title: "词汇", image: Lucide.bookOpen),
            .init(tab: .review, title: "复习", image: Lucide.sparkles),
            .init(tab: .profile, title: "我的", image: Lucide.user)
        ]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    HomeView()
                }
                .tag(Tab.home)

                StreamView()
                    .tag(Tab.stream)
            
                VacabularyView()
                    .tag(Tab.vocab)
            
                ReviewView()
                    .tag(Tab.review)
            
                ProfileView()
                    .tag(Tab.profile)
            }
            .accentColor(.thoughtStream.theme.green600)

            CustomTabBar(items: items, selected: $selectedTab, spring: spring)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
    }
}

private struct CustomTabBar: View {
    let items: [MainTabView.TabItemData]
    @Binding var selected: MainTabView.Tab
    let spring: Animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Button(action: {
                    withAnimation(spring) { selected = item.tab }
                }) {
                    VStack(spacing: 4) {
                        Image(uiImage: item.image)
                            .renderingMode(.template)
                            .foregroundColor(selected == item.tab ? .thoughtStream.theme.green600 : .secondary)
                            .scaleEffect(selected == item.tab ? 1.12 : 1.0)
                            .animation(spring, value: selected)
                        Text(item.title)
                            .font(.system(size: 11))
                            .foregroundColor(selected == item.tab ? .thoughtStream.theme.green600 : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - 预览
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
