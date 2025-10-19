import SwiftUI
import UIKit

struct CounterView: View {
    @AppStorage("counter.current") private var currentCount: Int = 0
    @AppStorage("counter.threshold") private var threshold: Int = 10
    @State private var showSettings: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            // 标题与说明
            VStack(spacing: 8) {
                Text("计次数")
                    .appFont(size: .xxl, weight: .bold)
                    .foregroundColor(.thoughtStream.neutral.gray800)
                Text("点击下方按钮进行计数，达阈值时触觉提醒")
                    .appFont(size: .sm, weight: .regular)
                    .foregroundColor(.thoughtStream.neutral.gray500)
            }

            // 当前计数显示
            VStack(spacing: 4) {
                Text("当前次数")
                    .appFont(size: .sm, weight: .medium)
                    .foregroundColor(.thoughtStream.neutral.gray600)
                Text("\(currentCount)")
                    .appFont(size: .xxxxl, weight: .bold)
                    .foregroundColor(.thoughtStream.neutral.gray800)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .appCard(cornerRadius: 16)

            // 主要操作按钮：+1
            Button(action: increment) {
                Text("+1")
                    .appFont(size: .xxl, weight: .bold)
                    .frame(maxWidth: .infinity)
            }
            .appPrimaryButtonStyle(cornerRadius: 12)

            // 次要操作：设置和重置
            HStack(spacing: 12) {
                Button(action: { showSettings = true }) {
                    Text("设置")
                        .appFont(size: .base, weight: .medium)
                        .frame(maxWidth: .infinity)
                }
                .appSecondaryButtonStyle(cornerRadius: 12)

                Button(action: reset) {
                    Text("重置")
                        .appFont(size: .base, weight: .medium)
                        .frame(maxWidth: .infinity)
                }
                .appDestructiveButtonStyle(cornerRadius: 12)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.thoughtStream.neutral.gray50)
        .navigationTitle("计次数")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSettings) {
            CounterSettingsView(threshold: $threshold)
        }
    }

    private func increment() {
        currentCount += 1
        checkHapticIfNeeded()
    }

    private func reset() {
        currentCount = 0
    }

    private func checkHapticIfNeeded() {
        guard threshold > 0 else { return }
        if currentCount % threshold == 0 {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CounterView()
        }
    }
}


