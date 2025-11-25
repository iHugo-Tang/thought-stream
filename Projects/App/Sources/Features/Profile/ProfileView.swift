import SwiftUI

struct ProfileView: View {
    var body: some View {
        List {
            Section {
                Text("ProfileView")
                    .listRowBackground(Color.clear)
            }
            .listSectionMargins(.vertical, 0)
            .listSectionSpacing(32)

            Section {
                Text("statistic")
            }
            
            Section {
                Text("achievments")
            }
            
            Section {
                Text("items")
            }
            
            Section {
                Text("Log out")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
    }
}

