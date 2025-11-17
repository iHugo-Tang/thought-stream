import SwiftUI

struct HistoryView: View {
    var body: some View {
        Text("HistoryView")
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
    }
}

