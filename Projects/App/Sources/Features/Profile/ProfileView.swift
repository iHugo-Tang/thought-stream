import SwiftUI

struct ProfileView: View {
    var body: some View {
        Text("ProfileView")
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
    }
}

