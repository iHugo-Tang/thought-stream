import SwiftUI

// MARK: - 色彩系统 (Color System)
// 将应用的所有颜色统一定义，方便统一管理和调用。

public extension Color {
    /// ThoughtStream 应用的主题和功能颜色
    static let thoughtStream = AppColors()

    struct AppColors {
        /// 主题色 - 绿色系列
        public let theme = ThemeColors()
        
        /// 中性色 - 灰色系列
        public let neutral = NeutralColors()
        
        /// 功能色 - 用于提示、警告等
        public let functional = FunctionalColors()
        
        /// 渐变色
        public let gradients = GradientColors()

        /// 基础色
        public let black = Color(hex: "#000000")
        public let white = Color(hex: "#FFFFFF")

        public struct ThemeColors {
            public let green50 = Color(hex: "#F0FDF4")
            public let green100 = Color(hex: "#DCFCE7")
            public let green600 = Color(hex: "#059669")
            public let green700 = Color(hex: "#047857")
            public let emerald100 = Color(hex: "#D1FAE5")
            public let emerald600 = Color(hex: "#10B981") // 补充的渐变色
            public let emerald700 = Color(hex: "#047857")
        }

        public struct NeutralColors {
            public let gray50 = Color(hex: "#F9FAFB")
            public let gray100 = Color(hex: "#F3F4F6")
            public let gray200 = Color(hex: "#E5E7EB")
            public let gray300 = Color(hex: "#D1D5DB")
            public let gray400 = Color(hex: "#9CA3AF")
            public let gray500 = Color(hex: "#6B7280")
            public let gray600 = Color(hex: "#4B5563")
            public let gray700 = Color(hex: "#374151")
            public let gray800 = Color(hex: "#1F2937")
        }

        public struct FunctionalColors {
            // 红色系列
            public let red100 = Color(hex: "#FEE2E2")
            public let red500 = Color(hex: "#EF4444")
            public let red600 = Color(hex: "#DC2626")
            public let red700 = Color(hex: "#B91C1C")
            
            // 蓝色系列
            public let blue100 = Color(hex: "#DBEAFE")
            public let blue600 = Color(hex: "#2563EB")
            public let blue700 = Color(hex: "#1D4ED8")
            
            // 黄色/琥珀色系列
            public let yellow100 = Color(hex: "#FEF3C7")
            public let yellow600 = Color(hex: "#D97706")
            
            // 紫色系列
            public let purple100 = Color(hex: "#F3E8FF")
            public let purple700 = Color(hex: "#7E22CE")
        }
        
        public struct GradientColors {
            /// Smart Summary 渐变
            public let smartSummary = LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#059669"), Color(hex: "#2563EB")]),
                startPoint: .leading,
                endPoint: .trailing
            )
            
            /// Spark of the Day 渐变
            public let sparkOfTheDay = LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#059669"), Color(hex: "#10B981")]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}


// MARK: - 字体系统 (Font System)
// 定义应用的字体大小和粗细，并通过 ViewModifier 应用。

/// 定义字体大小枚举，映射设计规范中的值
public enum AppFontSize: CGFloat {
    case xs = 12.0 // 0.75rem
    case sm = 14.0 // 0.875rem
    case base = 16.0 // 1rem
    case lg = 18.0 // 1.125rem
    case xl = 20.0 // 1.25rem
    case xxl = 24.0 // 1.5rem
    case xxxxl = 36.0 // 2.25rem
}

/// 定义字体粗细的便捷别名
public typealias AppFontWeight = Font.Weight

/// 自定义视图修饰符，用于应用字体样式
public struct AppFontModifier: ViewModifier {
    var size: AppFontSize
    var weight: AppFontWeight

    public func body(content: Content) -> some View {
        content.font(.system(size: size.rawValue, weight: weight))
    }
}

public extension View {
    /// 应用自定义字体样式
    /// - Parameters:
    ///   - size: 字体大小，来自 AppFontSize 枚举
    ///   - weight: 字体粗细，如 .bold, .medium 等
    /// - Returns: 应用了字体样式的视图
    func appFont(size: AppFontSize, weight: AppFontWeight = .regular) -> some View {
        self.modifier(AppFontModifier(size: size, weight: weight))
    }
}


// MARK: - Helper
// 用于从十六进制颜色码创建 Color 对象的辅助扩展。

// MARK: - Reusable Style Helpers
public extension View {
    /// 卡片样式（白底，圆角，轻阴影）
    func appCard(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(Color.thoughtStream.white)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
    }

    /// 主要按钮样式（绿色背景，白字，圆角）
    func appPrimaryButtonStyle(cornerRadius: CGFloat = 8) -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.thoughtStream.theme.green600)
            .foregroundColor(.white)
            .cornerRadius(cornerRadius)
    }

    /// 胶囊标签样式（用于 Free、状态等）
    func appCapsuleTag(background: Color, foreground: Color, horizontal: CGFloat = 8, vertical: CGFloat = 4) -> some View {
        self
            .padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
            .background(background)
            .foregroundColor(foreground)
            .cornerRadius(9999)
    }
}

fileprivate extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 使用示例 (Usage Example)
// 下方是一个如何使用此设计系统的示例。

struct DesignSystemUsageExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题
            Text("ThoughtStream App")
                .appFont(size: .xxl, weight: .bold)
                .foregroundColor(.thoughtStream.neutral.gray800)

            // 卡片示例
            VStack(alignment: .leading) {
                Text("今日灵感 (Spark of the Day)")
                    .appFont(size: .lg, weight: .bold)
                    .foregroundColor(.white)
                Text("这是一个使用渐变背景和自定义字体的卡片示例。")
                    .appFont(size: .sm, weight: .regular)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.thoughtStream.gradients.sparkOfTheDay)
            .cornerRadius(12)

            // 按钮
            Button(action: {}) {
                Text("主按钮")
                    .appFont(size: .base, weight: .medium)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.thoughtStream.theme.green600)
                    .cornerRadius(8)
            }
            
            // 标签
            HStack {
                Text("成功标签")
                    .appFont(size: .xs, weight: .medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.thoughtStream.theme.green100)
                    .foregroundColor(Color.thoughtStream.theme.green700)
                    .cornerRadius(12)
                
                Text("错误提示")
                    .appFont(size: .xs, weight: .medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.thoughtStream.functional.red100)
                    .foregroundColor(Color.thoughtStream.functional.red700)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.thoughtStream.neutral.gray50)
    }
}

struct DesignSystemUsageExample_Previews: PreviewProvider {
    static var previews: some View {
        DesignSystemUsageExample()
    }
}
