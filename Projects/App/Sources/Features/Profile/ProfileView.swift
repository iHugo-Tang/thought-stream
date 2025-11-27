import SwiftUI

struct ProfileView: View {
    var body: some View {
        List {
            avatarSection
                .listRowInsets(.vertical, 0)

            Section {
                HStack(spacing: 16) {
                    statisticLearningTime
                        .frame(maxWidth: .infinity)
                    statisticCompleted
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.all, 0)
            }

            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Achievements")
                        .font(FontSize.headline.font())
                        .foregroundColor(.asset.textPrimary)
                    
                    HStack(spacing: 16) {
                        AchievementBadgeView(
                            title: "First Course",
                            image: ThoughtStreamAsset.Assets.achievementCourse.swiftUIImage,
                            backgroundColor: .asset.iconBgPrimary,
                            iconSize: CGSize(width: 30, height: 36),
                            flipVertically: true
                        )
                        
                        AchievementBadgeView(
                            title: "7-Day Streak",
                            image: ThoughtStreamAsset.Assets.achievementStreak.swiftUIImage,
                            backgroundColor: .asset.iconBgPrimary,
                            iconSize: CGSize(width: 30, height: 36),
                            flipVertically: true
                        )
                        
                        AchievementBadgeView(
                            title: "Grammar Pro",
                            image: ThoughtStreamAsset.Assets.achievementGrammar.swiftUIImage,
                            backgroundColor: .asset.iconBgPrimary,
                            iconSize: CGSize(width: 30, height: 36),
                            flipVertically: true
                        )
                        
                        AchievementBadgeView(
                            title: "10 Courses",
                            image: ThoughtStreamAsset.Assets.achievementLocker.swiftUIImage,
                            backgroundColor: .asset.iconBgSecondary,
                            iconSize: CGSize(width: 30, height: 36),
                            flipVertically: true
                        )
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.vertical, 0)
            }

            Section {
                Text("Help & Feedback")
                    .font(FontSize.bodyEmphasis.font())
                    .listRowBackground(Color.asset.bgSecondary)
                
                Text("Privacy Policy")
                    .font(FontSize.bodyEmphasis.font())
                    .listRowBackground(Color.asset.bgSecondary)
                
                Text("About Us")
                    .font(FontSize.bodyEmphasis.font())
                    .listRowBackground(Color.asset.bgSecondary)
            }
            .listRowSeparatorTint(.asset.seperator1)
            .foregroundColor(.asset.textPrimary)
            
            Section {
                LargeButton(buttonType: .destructive, title: "Log Out")
                    .listRowBackground(Color.clear)
                    .listRowInsets(.all, 0)
            }
        }
        .listSectionSpacing(24)
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.asset.bgPrimary)
    }
    
    var avatarSection: some View {
        Section {
            HStack(spacing: 16) {
                ThoughtStreamAsset.Assets.avatarPlaceholder.swiftUIImage
                    .resizable()
                    .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Alex Thompson")
                        .font(FontSize.title.font())
                        .foregroundColor(.asset.textPrimary)
                    
                    Button {
                    } label: {
                        Text("Edit Profile")
                            .font(FontSize.button.font())
                            .foregroundColor(.asset.btnPrimary)
                    }

                }
            }
            .listRowBackground(Color.clear)
        }
    }
    
    var statisticLearningTime: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Total Learning Time")
                .font(FontSize.caption.font())
                .foregroundColor(.asset.textSecondary)
            Text("128h")
                .font(FontSize.headline.font())
                .foregroundColor(.asset.textPrimary)
        }
        .padding()
        .background(Color.asset.bgSecondary)
        .cornerRadius(CornerSize.medium)
    }
    
    var statisticCompleted: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Total Learning Time")
                .font(FontSize.caption.font())
                .foregroundColor(.asset.textSecondary)
            Text("128h")
                .font(FontSize.headline.font())
                .foregroundColor(.asset.textPrimary)
        }
        .padding()
        .background(Color.asset.bgSecondary)
        .cornerRadius(CornerSize.medium)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
    }
}

