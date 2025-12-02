import SwiftUI

struct SegmentBar: View {
    @State private var tabWidth: CGFloat = 0
    @State private var selectedTab: Int = 0
    @State private var frames: [CGRect] = [.zero, .zero, .zero, .zero]

    let tabs: [String] = ["Summary", "Grammar", "Vocabulary", "Suggestions"]
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HStack {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button(action: {
                        withAnimation {
                            selectedTab = index
                        }
                    }) {
                        Text(tab)
                            .font(FontSize.caption.font())
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .readFrame(in: .named("MyCustomParent")) { frame in
                                tabWidth = frame.size.width
                                self.frames[index] = frame
                            }
                    }
                    .tint(
                        selectedTab == index
                        ? .asset.btnPrimary
                        : .asset.textPrimary
                    )
                }
            }
            .coordinateSpace(name: "MyCustomParent")
            
            Rectangle()
                .fill(Color.asset.btnPrimary)
                .frame(width: max(0, tabWidth-16), height: 2)
                .animation(.easeInOut, value: selectedTab)
                .offset(x: frames[selectedTab].midX - tabWidth/2 + 8)
        }
    }
}

#Preview {
    VStack {
        SegmentBar()
            .padding(.horizontal)
    }
}
