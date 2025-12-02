import SwiftUI

struct FontToken {
    let size: Int
    let weight: Font.Weight

    func font(family: String = "Inter") -> Font {
        Font.custom(family, size: CGFloat(size)).weight(weight)
    }
}

enum FontSize {
    /// Oversized numbers or hero headlines.
    static let display = FontToken(size: 40, weight: .bold)

    /// Primary page titles and greetings.
    static let title = FontToken(size: 24, weight: .bold)

    /// Section headers and highlighted quotes.
    static let headline = FontToken(size: 20, weight: .bold)

    /// General supporting body copy.
    static let body = FontToken(size: 18, weight: .regular)

    /// Emphasized body text (e.g., metrics deltas, authors).
    static let bodyEmphasis = FontToken(size: 16, weight: .medium)

    /// Primary/secondary CTA labels.
    static let button = FontToken(size: 16, weight: .bold)

    /// Secondary descriptive copy.
    static let caption = FontToken(size: 14, weight: .regular)

    /// Compact pill or badge labels.
    static let captionStrong = FontToken(size: 14, weight: .bold)

    /// Smallest labels such as tab bar text.
    static let footnote = FontToken(size: 12, weight: .medium)
}

