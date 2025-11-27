// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist


#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// MARK: - Asset Catalogs

public enum ThoughtStreamAsset: Sendable {
  public enum Assets {
    public static let accentColor = ThoughtStreamColors(name: "AccentColor")
    public static let achievementCourse = ThoughtStreamImages(name: "AchievementCourse")
    public static let achievementGrammar = ThoughtStreamImages(name: "AchievementGrammar")
    public static let achievementLocker = ThoughtStreamImages(name: "AchievementLocker")
    public static let achievementStreak = ThoughtStreamImages(name: "AchievementStreak")
    public static let avatarPlaceholder = ThoughtStreamImages(name: "AvatarPlaceholder")
  }
  public enum Colors {
    public static let bgPrimary = ThoughtStreamColors(name: "BgPrimary")
    public static let bgSecondary = ThoughtStreamColors(name: "BgSecondary")
    public static let btnPrimary = ThoughtStreamColors(name: "BtnPrimary")
    public static let btnSecondary = ThoughtStreamColors(name: "BtnSecondary")
    public static let btnTertiary = ThoughtStreamColors(name: "BtnTertiary")
    public static let btnWarn = ThoughtStreamColors(name: "BtnWarn")
    public static let iconBgPrimary = ThoughtStreamColors(name: "IconBgPrimary")
    public static let iconBgSecondary = ThoughtStreamColors(name: "IconBgSecondary")
    public static let iconPrimary = ThoughtStreamColors(name: "IconPrimary")
    public static let seperator1 = ThoughtStreamColors(name: "Seperator1")
    public static let tagGreen = ThoughtStreamColors(name: "TagGreen")
    public static let tagOrange = ThoughtStreamColors(name: "TagOrange")
    public static let tagPurple = ThoughtStreamColors(name: "TagPurple")
    public static let textAccentInteractive = ThoughtStreamColors(name: "TextAccentInteractive")
    public static let textAccentPositive = ThoughtStreamColors(name: "TextAccentPositive")
    public static let textPlaceholder = ThoughtStreamColors(name: "TextPlaceholder")
    public static let textPrimary = ThoughtStreamColors(name: "TextPrimary")
    public static let textSecondary = ThoughtStreamColors(name: "TextSecondary")
  }
  public enum PreviewAssets {
    public static let placeholder = ThoughtStreamImages(name: "placeholder")
  }
}

// MARK: - Implementation Details

public final class ThoughtStreamColors: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  public var color: Color {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIColor: SwiftUI.Color {
      return SwiftUI.Color(asset: self)
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ThoughtStreamColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: ThoughtStreamColors) {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Color {
  init(asset: ThoughtStreamColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct ThoughtStreamImages: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Image {
  init(asset: ThoughtStreamImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ThoughtStreamImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ThoughtStreamImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// MARK: - Custom Color Accessor

extension Color {
    static var asset: AssetColors {
        AssetColors()
    }

    struct AssetColors {
        var accentColor: Color { ThoughtStreamAsset.Assets.accentColor.swiftUIColor }
        var bgPrimary: Color { ThoughtStreamAsset.Colors.bgPrimary.swiftUIColor }
        var bgSecondary: Color { ThoughtStreamAsset.Colors.bgSecondary.swiftUIColor }
        var btnPrimary: Color { ThoughtStreamAsset.Colors.btnPrimary.swiftUIColor }
        var btnSecondary: Color { ThoughtStreamAsset.Colors.btnSecondary.swiftUIColor }
        var btnTertiary: Color { ThoughtStreamAsset.Colors.btnTertiary.swiftUIColor }
        var btnWarn: Color { ThoughtStreamAsset.Colors.btnWarn.swiftUIColor }
        var iconBgPrimary: Color { ThoughtStreamAsset.Colors.iconBgPrimary.swiftUIColor }
        var iconBgSecondary: Color { ThoughtStreamAsset.Colors.iconBgSecondary.swiftUIColor }
        var iconPrimary: Color { ThoughtStreamAsset.Colors.iconPrimary.swiftUIColor }
        var seperator1: Color { ThoughtStreamAsset.Colors.seperator1.swiftUIColor }
        var tagGreen: Color { ThoughtStreamAsset.Colors.tagGreen.swiftUIColor }
        var tagOrange: Color { ThoughtStreamAsset.Colors.tagOrange.swiftUIColor }
        var tagPurple: Color { ThoughtStreamAsset.Colors.tagPurple.swiftUIColor }
        var textAccentInteractive: Color { ThoughtStreamAsset.Colors.textAccentInteractive.swiftUIColor }
        var textAccentPositive: Color { ThoughtStreamAsset.Colors.textAccentPositive.swiftUIColor }
        var textPlaceholder: Color { ThoughtStreamAsset.Colors.textPlaceholder.swiftUIColor }
        var textPrimary: Color { ThoughtStreamAsset.Colors.textPrimary.swiftUIColor }
        var textSecondary: Color { ThoughtStreamAsset.Colors.textSecondary.swiftUIColor }
    }
}


