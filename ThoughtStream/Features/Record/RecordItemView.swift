import SwiftUI

struct RecordItemView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("英语批改")
                    .foregroundColor(Color.thoughtStream.bg.indigo800)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .appFont(size: .xs)
                    .background(RoundedRectangle(cornerRadius: CornerRadius.sm.rawValue).fill(Color.thoughtStream.bg.indigo100.opacity(0.5)))
                Text("19:08")
                    .appFont(size: .sm)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("I've updated the rewriting API to remove the...")
                    .appFont(size: .base)
                Text("I've updated the rewriting API to remove the...")
                    .appFont(size: .base)
                    .foregroundColor(.thoughtStream.theme.green600)
            }
        }
    }
}

#Preview {
    RecordItemView()
}
