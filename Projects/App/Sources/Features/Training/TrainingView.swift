import SwiftUI

struct TrainingView: View {

    var body: some View {
        Text("ProfileView")
    }
}

#Preview {
    NavigationStack {
        TrainingView()
            .navigationTitle("Training")
            .navigationBarTitleDisplayMode(.large)
    }
}

