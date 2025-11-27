import SwiftUI

struct TrainingView: View {
    @State private var text = ""
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.asset.bgPrimary.ignoresSafeArea()
            VStack(spacing: 16) {
                VStack(alignment: .center, spacing: 8) {
                    Text("The limits of my language \nmean the limits of my world.")
                        .multilineTextAlignment(.center)
                        .font(FontSize.headline.font())
                        .foregroundColor(.asset.textPrimary)
                    Text("- Ludwig Wittgenstein")
                        .font(FontSize.bodyEmphasis.font())
                        .foregroundColor(.asset.textSecondary)
                }
                
                TextField(
                    "Enter your answer",
                    text: $text,
                    prompt: Text("Enter your answer").foregroundColor(.asset.textPlaceholder),
                    axis: .vertical
                )
                .frame(maxHeight: .infinity, alignment: .top)
                .padding()
                .background(Color.asset.bgSecondary)
                .cornerRadius(CornerSize.small)
                .overlay(alignment: .bottomTrailing) {
                    Button(action: {
                        print("..")
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.asset.btnPrimary)
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

