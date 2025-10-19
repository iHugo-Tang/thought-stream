import SwiftUI

struct CounterSettingsView: View {
    @Binding var threshold: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("提醒阈值").appFont(size: .sm, weight: .medium)) {
                    Stepper(value: $threshold, in: 1...500) {
                        HStack {
                            Text("每 \(threshold) 次触发一次触觉反馈")
                                .appFont(size: .base, weight: .regular)
                                .foregroundColor(.thoughtStream.neutral.gray800)
                        }
                    }
                }

                Section(footer: Text("当计数达到设置的倍数时，将触发一次成功类型的触觉反馈。可在主界面点击“+1”测试。")
                    .appFont(size: .xs, weight: .regular)
                    .foregroundColor(.thoughtStream.neutral.gray500)) {
                    EmptyView()
                }
            }
            .navigationTitle("计数设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

struct CounterSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CounterSettingsView(threshold: .constant(10))
    }
}


