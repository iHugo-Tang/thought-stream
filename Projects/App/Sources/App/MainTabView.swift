import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                HistoryView()
                    .navigationTitle("Knowledge Hub")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }

            NavigationStack {
                TrainingView()
                    .navigationTitle("Free Practice")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Training", systemImage: "bolt.badge.a.fill")
            }

            NavigationStack {
                ProfileView()
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
        }
        .tint(Color("AccentColor"))
        .background(ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor.ignoresSafeArea())
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor, for: .tabBar)
    }
}

#Preview {
    MainTabView()
}

