import SwiftUI

struct TrainingView: View {
    @State private var text = ""
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor.ignoresSafeArea()
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
                .frame(maxHeight: .infinity, alignment: .top)
                .padding()
                .background(ThoughtStreamAsset.Colors.bgSecondary.swiftUIColor)
                .cornerRadius(CornerSize.small)
                .overlay(alignment: .bottomTrailing) {
                    Button(action: {
                        print("..")
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(ThoughtStreamAsset.Colors.btnPrimary.swiftUIColor)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .padding()
                }
                
                LargeButton(buttonType: .primary, title: "Submit") {
                    
                }
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        TrainingView()
            .navigationTitle("Training")
            .navigationBarTitleDisplayMode(.large)
    }
}

