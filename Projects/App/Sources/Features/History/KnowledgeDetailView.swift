import SwiftUI

struct KnowledgeDetailView: View {
    var body: some View {
        ScrollView {
            HStack {
                Text("October 29, 2023")
                    .font(FontSize.caption.font())
                    .foregroundColor(.asset.textSecondary)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                SegmentBar()
                    .padding(.horizontal)
                Divider()
                    .background(Color.asset.textPrimary)
            }
            
            VStack(spacing: 16) {
                OverallScoreView()
                KeyTakeawaysView()
                KeyTakeawaysView()
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.asset.bgPrimary)
    }
}

struct OverallScoreView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Overall Score")
                    .font(FontSize.bodyEmphasis.font())
                    .foregroundColor(.asset.textPrimary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    ThoughtStreamAsset.Assets.iconThumbUp.swiftUIImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .fontWeight(.medium)
                    
                    Text("Great Job")
                        .font(FontSize.footnote.font())
                        .foregroundColor(.asset.btnGreen)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Color.asset.btnBgGreen
                )
                .clipShape(Capsule())
            }
            
            Text("You did an excellent job of using the idiom \"break the ice\" in a natural and contextually appropriate way. Your pronunciation was clear and your sentence structure was grammatically correct.")
                .font(FontSize.caption.font())
                .foregroundColor(.asset.textSecondary)
        }
        .padding()
        .background(Color.asset.bgSecondary.cornerRadius(CornerSize.medium))
        .padding()
    }
}

struct KeyTakeawaysView: View {
    var body: some View {
        Text("KeyTakeawaysView")
    }
}

struct ImprovementView: View {
    var body: some View {
        Text("ImprovementView")
    }
}

#Preview {
    NavigationStack {
        KnowledgeDetailView()
            .navigationTitle("Idiom: Break the ice")
    }
}
