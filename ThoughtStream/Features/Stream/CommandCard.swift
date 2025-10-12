import SwiftUI

struct CommandCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing(.lg)) {
            Text("英语修改建议")
                .appFont(size: .base)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.thoughtStream.bg.indigo600)
            
            VStack(alignment: .leading, spacing: .spacing(.lg)) {
                VStack(alignment: .leading, spacing: .spacing(.base)) {
                    Text("原句")
                        .appFont(size: .base, weight: .bold)
                    Text("I've updated the rewriting API to remove the suggestions and reviews fields.")
                        .appFont(size: .base)
                        .padding()
                        .background(Color.thoughtStream.neutral.gray100)
                        .cornerRadius(.spacing(.base))
                }
                
                VStack(alignment: .leading, spacing: .spacing(.base)) {
                    Text("修改")
                        .appFont(size: .base, weight: .bold)
                    Text("I've updated the rewriting API to remove the suggestions and reviews fields.")
                        .appFont(size: .base)
                        .padding()
                        .background(Color.thoughtStream.theme.green100)
                        .cornerRadius(.spacing(.base))
                }
                
                VStack(alignment: .leading, spacing: .spacing(.base)) {
                    Text("说明:")
                        .appFont(size: .base, weight: .bold)
                    VStack(alignment: .leading, spacing: .spacing(.base)) {
                        Text("1. After 'have', the verb should be in the past participle form. For 'update', it's 'updated'.")
                            .appFont(size: .base)
                        Text("2. It's more natural to contract 'I have' to 'I've' in conversation.")
                            .appFont(size: .base)
                        Text("3. Acronyms like 'API' should be capitalized.")
                            .appFont(size: .base)
                    }
                    .padding()
                    .background(Color.thoughtStream.neutral.gray100)
                    .cornerRadius(.spacing(.base))
                }
            }.padding(.horizontal)
        }.cornerRadius(10)
    }
}

#Preview {
    CommandCard()
}
