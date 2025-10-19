import SwiftUI

final class MainTabViewModel: ObservableObject {
    enum Tab: Hashable {
        case home
        case stream
        case vocab
        case review
        case profile
    }

    @Published var selectedTab: Tab = .home
    @Published var tabBarHeight: CGFloat = 0
    @Published var isTabBarHidden: Bool = false

    let spring: Animation = .spring(response: 0.3, dampingFraction: 0.7)

    func setTabBarHidden(_ hidden: Bool) {
        withAnimation(spring) {
            isTabBarHidden = hidden
        }
    }
}


