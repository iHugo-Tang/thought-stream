import SwiftUI

struct TrainingView: View {
    @State private var text = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .center, spacing: 8) {
                        Text("The limits of my language \nmean the limits of my world.")
                            .multilineTextAlignment(.center)
                            .font(FontSize.headline.font())
                            .foregroundColor(ThoughtStreamAsset.Colors.textPrimary.swiftUIColor)
                        Text("- Ludwig Wittgenstein")
                            .font(FontSize.bodyEmphasis.font())
                            .foregroundColor(ThoughtStreamAsset.Colors.textSecondary.swiftUIColor)
                    }
                    
                    TextField(
                        "Enter your answer",
                        text: $text,
                        prompt: Text("Enter your answer").foregroundColor(ThoughtStreamAsset.Colors.textPlaceholder.swiftUIColor),
                        axis: .vertical
                    )
                    .frame(minHeight: 120, alignment: .top)
                    .padding()
                    .background(ThoughtStreamAsset.Colors.bgSecondary.swiftUIColor)
                    .cornerRadius(CornerSize.small)
                }
                .padding()
            }
            
            VStack {
                LargeButton(buttonType: .primary, title: "Submit") {
                    
                }
            }
            .padding()
        }
        .background(ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor)
    }
}

#Preview {
    NavigationStack {
        TrainingView()
            .navigationTitle("Training")
            .navigationBarTitleDisplayMode(.large)
    }
}

