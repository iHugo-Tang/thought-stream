import SwiftUI
import LucideIcons

struct HomeView: View {
    @Environment(\.tabBarHeight) private var tabBarHeight
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 工具入口. 这里显示一系列工具.
            VStack(alignment: .leading, spacing: 16) {
                NavigationLink(destination: CounterView().hideTabBarOnPush()) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "number.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                            .appCircularButton(size: 44,
                                              background: Color.thoughtStream.theme.green700,
                                              foreground: .white,
                                              shadowOpacity: 0.12,
                                              shadowRadius: 8,
                                              shadowYOffset: 4)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("计次数")
                                .appFont(size: .lg, weight: .bold)
                                .foregroundColor(.thoughtStream.neutral.gray800)
                            Text("点击+1，达到阈值触觉提醒")
                                .appFont(size: .sm, weight: .regular)
                                .foregroundColor(.thoughtStream.neutral.gray500)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.thoughtStream.neutral.gray300)
                    }
                    .padding(16)
                    .appCard(cornerRadius: 12)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 悬浮写作按钮（位于自定义 TabBar 顶部 8pt）
            NavigationLink(destination: ChatView().hideTabBarOnPush()) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.thoughtStream.theme.green600)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 16)
            .padding(.bottom, tabBarHeight + 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.thoughtStream.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(uiImage: Lucide.brain)
                        .renderingMode(.template)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.thoughtStream.neutral.gray800)
                    Text("ThoughtStream")
                        .appFont(size: .lg, weight: .bold)
                        .foregroundColor(.thoughtStream.neutral.gray800)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Text("Free")
                    .appFont(size: .xs, weight: .regular)
                    .appCapsuleTag(background: .thoughtStream.theme.green100, foreground: .thoughtStream.theme.green700)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
//        HomeView()
        MainTabView()
    }
}
