import SwiftUI
import LucideIcons

struct HomeView: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    dailyGoalsCard
                    sparkOfTheDayCard
                    recentStreams
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 140) // 为底部 Tab 与悬浮按钮预留空间
            }
            .background(Color.thoughtStream.neutral.gray50)

            // 悬浮写作按钮
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.thoughtStream.theme.green600)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 80)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.thoughtStream.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 8) {
                    Image(uiImage: Lucide.brain)
                        .renderingMode(.template)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.thoughtStream.theme.green600)
                    Text("ThoughtStream")
                        .appFont(size: .lg, weight: .bold)
                        .foregroundColor(.thoughtStream.neutral.gray800)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("Free")
                    .appFont(size: .xs, weight: .regular)
                    .appCapsuleTag(background: .thoughtStream.theme.green100, foreground: .thoughtStream.theme.green700)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("Good evening, Eva!")
                    .appFont(size: .lg, weight: .medium)
                    .foregroundColor(.thoughtStream.neutral.gray800)
                Text("🌙")
            }
            Text("Saturday, August 30")
                .appFont(size: .sm)
                .foregroundColor(.thoughtStream.neutral.gray500)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var dailyGoalsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Daily Goals")
                    .appFont(size: .base, weight: .medium)
                    .foregroundColor(.thoughtStream.neutral.gray700)
                Spacer()
            }

            HStack(alignment: .center, spacing: 12) {
                // 左侧对勾图标圈
                ZStack {
                    Circle()
                        .stroke(Color.thoughtStream.neutral.gray300, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 12, height: 12)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 0) {
                        Text("Daily review complete!")
                            .appFont(size: .sm)
                            .foregroundColor(.thoughtStream.neutral.gray700)
                        Text(" ")
                            .appFont(size: .sm)
                            .foregroundColor(.thoughtStream.neutral.gray700)
                        Text("Awesome job.")
                            .appFont(size: .sm, weight: .medium)
                            .foregroundColor(.thoughtStream.theme.green600)
                    }
                }
            }

            HStack(alignment: .center, spacing: 12) {
                // 进度条
                ZStack(alignment: .leading) {
                    Capsule()
                        .stroke(Color.thoughtStream.neutral.gray300, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 12, height: 12)
                }.frame(width: 24, height: 24)

                Text("Write 1 Stream to meet your daily goal.")
                    .appFont(size: .sm)
                    .foregroundColor(.thoughtStream.neutral.gray700)
            }
        }
        .padding(20)
        .appCard(cornerRadius: 12)
    }

    private var sparkOfTheDayCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部渐变标题
            HStack(spacing: 12) {
                Image(uiImage: Lucide.sparkles)
                    .renderingMode(.template)
                    .foregroundColor(.thoughtStream.white)
                Text("Spark of the Day")
                    .appFont(size: .sm, weight: .medium)
                    .foregroundColor(.thoughtStream.white)
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(Color.thoughtStream.gradients.sparkOfTheDay)

            VStack(alignment: .leading, spacing: 16) {
                // 问题标题
                VStack(alignment: .leading, spacing: 4) {
                    Text("What was the highlight of your")
                        .appFont(size: .lg, weight: .bold)
                        .foregroundColor(.thoughtStream.neutral.gray800)
                    Text("weekend so far?")
                        .appFont(size: .lg, weight: .bold)
                        .foregroundColor(.thoughtStream.neutral.gray800)
                }

                // 提示块
                VStack(alignment: .leading, spacing: 8) {
                    Text("Whether it was a quiet moment with a cup of")
                        .appFont(size: .sm)
                        .foregroundColor(.thoughtStream.neutral.gray700)
                    Text("tea, a fun outing with family, or finishing a")
                        .appFont(size: .sm)
                        .foregroundColor(.thoughtStream.neutral.gray700)
                    Text("chapter of a good book, describe it in a few")
                        .appFont(size: .sm)
                        .foregroundColor(.thoughtStream.neutral.gray700)
                    Text("sentences.")
                        .appFont(size: .sm)
                        .foregroundColor(.thoughtStream.neutral.gray700)
                }
                .padding(16)
                .background(Color.thoughtStream.theme.green50)
                .cornerRadius(8)

                Text("Key Phrases you could use:")
                    .appFont(size: .sm, weight: .medium)
                    .foregroundColor(.thoughtStream.neutral.gray700)

                VStack(alignment: .leading, spacing: 8) {
                    Text("• to unwind - 放松")
                        .appFont(size: .sm)
                        .foregroundColor(.thoughtStream.neutral.gray600)
                    Text("• quality time - 优质时光")
                        .appFont(size: .sm)
                        .foregroundColor(.thoughtStream.neutral.gray600)
                    Text("• a pleasant surprise - 一个惊喜")
                        .appFont(size: .sm)
                        .foregroundColor(.thoughtStream.neutral.gray600)
                }

                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(uiImage: Lucide.squarePen)
                            .renderingMode(.template)
                        Text("Respond to this Spark")
                            .appFont(size: .sm)
                    }
                    .foregroundColor(.thoughtStream.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.thoughtStream.theme.green600)
                    .cornerRadius(8)
                }
            }
            .padding(24)
        }
        .appCard(cornerRadius: 12)
    }

    private var recentStreams: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Streams")
                .appFont(size: .sm, weight: .medium)
                .foregroundColor(.thoughtStream.neutral.gray700)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sampleStreams, id: \.title) { item in
                        streamCard(title: item.title, date: item.date)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func streamCard(title: String, date: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .appFont(size: .sm)
                .foregroundColor(.thoughtStream.neutral.gray700)
                .lineLimit(2)
                .frame(height: 40, alignment: .topLeading)
            HStack {
                Text(date)
                    .appFont(size: .xs)
                    .foregroundColor(.thoughtStream.neutral.gray500)
                Spacer()
            }
        }
        .padding(16)
        .frame(width: 250, height: 100, alignment: .topLeading)
        .appCard(cornerRadius: 12)
    }

    private var sampleStreams: [(title: String, date: String)] {
        [
            ("My thoughts on the new project...", "Aug 29"),
            ("Practicing describing my favorite...", "Aug 28"),
            ("The AI feedback on this was super...", "Aug 26")
        ]
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
//        HomeView()
        MainTabView()
    }
}
