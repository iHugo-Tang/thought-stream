import SwiftUI

struct RecordSection: View {
    let date: Date
    
    var title: String {
        DateFormaterHelper.dayAgo(from: date)
    }
    
    var body: some View {
        Text("\(title)")
            .appFont(size: .sm)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    RecordSection(date: Date())
}
