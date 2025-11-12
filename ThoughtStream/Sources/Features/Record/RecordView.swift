import SwiftUI

struct RecordView: View {
    var body: some View {
        List {
            Section(header: RecordSection(date: .init())) {
                RecordItemView()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .appCard()
            }
            .listRowSeparator(.hidden)
            .listSectionMargins(.all, 0)
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("记录")
    }
}

#Preview {
    NavigationView {
        RecordView()
    }
}
