import SwiftUI
import LucideIcons

struct MainTabView: View {
    
    // 使用 init() 来自定义 TabBar 的全局外观
    init() {
        // 设置 TabBar 的背景颜色
        // UITabBar.appearance() 在 SwiftUI 中用于全局配置
        UITabBar.appearance().backgroundColor = UIColor(Color.thoughtStream.white)
        // 你也可以设置一个半透明的背景
        UITabBar.appearance().isHidden = true
    }

    @StateObject private var viewModel = MainTabViewModel()

    struct TabItemData: Identifiable {
        let tab: MainTabViewModel.Tab
        let title: String
        let image: UIImage
        var id: MainTabViewModel.Tab { tab }
    }

    private var items: [TabItemData] {
        [
            .init(tab: .home, title: "主页", image: Lucide.house),
            .init(tab: .stream, title: "思绪", image: Lucide.pen),
            .init(tab: .vocab, title: "输出", image: Lucide.bookOpen),
            .init(tab: .profile, title: "我的", image: Lucide.user)
        ]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.selectedTab) {
                NavigationView {
                    HomeView()
                }
                .tag(MainTabViewModel.Tab.home)

                NavigationView {
                    StreamView()
                }
                .tag(MainTabViewModel.Tab.stream)
            
                VacabularyView()
                    .tag(MainTabViewModel.Tab.vocab)
            
                ReviewView()
                    .tag(MainTabViewModel.Tab.review)
            
                ProfileView()
                    .tag(MainTabViewModel.Tab.profile)
            }
            .accentColor(.thoughtStream.theme.green600)
            // 将测得的 TabBar 高度下发到子树（如 HomeView）以便内部定位浮动按钮
            .environment(\.tabBarHeight, viewModel.isTabBarHidden ? 0 : viewModel.tabBarHeight)
            .environment(\.setTabBarHidden, viewModel.setTabBarHidden)

            // Custom TabBar
            CustomTabBar(items: items, selected: $viewModel.selectedTab, spring: viewModel.spring)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                // Measure the rendered height of the TabBar (including paddings)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: CustomTabBarHeightPreferenceKey.self, value: proxy.size.height)
                    }
                )
                .onPreferenceChange(CustomTabBarHeightPreferenceKey.self) { value in
                    viewModel.tabBarHeight = value
                }
                .opacity(viewModel.isTabBarHidden ? 0 : 1)
                .animation(viewModel.spring, value: viewModel.isTabBarHidden)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

private struct CustomTabBar: View {
    let items: [MainTabView.TabItemData]
    @Binding var selected: MainTabViewModel.Tab
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

// MARK: - PreferenceKey for capturing TabBar height
private struct CustomTabBarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Environment for propagating TabBar height to child views
struct TabBarHeightEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var tabBarHeight: CGFloat {
        get { self[TabBarHeightEnvironmentKey.self] }
        set { self[TabBarHeightEnvironmentKey.self] = newValue }
    }
}

// MARK: - Environment for controlling TabBar visibility
private struct SetTabBarHiddenKey: EnvironmentKey {
    static let defaultValue: (Bool) -> Void = { _ in }
}

extension EnvironmentValues {
    var setTabBarHidden: (Bool) -> Void {
        get { self[SetTabBarHiddenKey.self] }
        set { self[SetTabBarHiddenKey.self] = newValue }
    }
}

// MARK: - View modifier for hiding TabBar on push
private struct HideTabBarOnPush: ViewModifier {
    @Environment(\.setTabBarHidden) private var setTabBarHidden
    func body(content: Content) -> some View {
        content
            .onAppear { setTabBarHidden(true) }
            .onDisappear { setTabBarHidden(false) }
    }
}

extension View {
    func hideTabBarOnPush() -> some View {
        modifier(HideTabBarOnPush())
    }
}

// MARK: - 预览
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
