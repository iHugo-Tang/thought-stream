import SwiftUI
import LucideIcons

struct MainTabView: View {
    
    init() {
    }
    
    @StateObject private var viewModel = MainTabViewModel()
    
    struct TabItemData: Identifiable {
        let tab: MainTabViewModel.Tab
        let title: String
        let image: UIImage
        let content: () -> AnyView
        var id: MainTabViewModel.Tab { tab }
    }
    
    private var items: [TabItemData] {
        [
            .init(
                tab: .home,
                title: "主页",
                image: Lucide.house,
                content: { AnyView(NavigationView { HomeView() }) }
            ),
            .init(
                tab: .stream,
                title: "思绪",
                image: Lucide.pen,
                content: { AnyView(NavigationView { StreamView() }) }
            ),
            .init(
                tab: .review,
                title: "记录",
                image: Lucide.bookOpen,
                content: { AnyView(NavigationView { RecordView() }) }
            ),
            .init(
                tab: .profile,
                title: "我的",
                image: Lucide.user,
                content: { AnyView(ProfileView()) }
            )
        ]
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.selectedTab) {
                ForEach(items) { item in
                    NavigationStack {
                        item.content()
                    }
                    .tag(item.tab)
                    .tabItem {
                        Label {
                            Text(item.title)
                                .font(.system(size: 11))
                        } icon: {
                            Image(uiImage: item.image)
                        }
                    }
                }
            }
            .accentColor(.thoughtStream.theme.green600)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - 预览
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
