// swift-tools-version:6.2
import PackageDescription

let packageName = "ThoughtStream"
let package = Package(
  name: packageName,
  platforms: [.iOS("17.0")],
  products: [
    .library(name: packageName, targets: [packageName])
  ],
  dependencies: [
      .package(url: "https://github.com/JakubMazur/lucide-icons-swift", from: "0.542.0"),
      .package(url: "https://github.com/QMUI/LookinServer", from: "1.2.8")
  ],
  targets: [
    .target(
      name: packageName,
      dependencies: [
        .product(name: "LucideIcons", package: "lucide-icons-swift"),
        .product(name: "LookinServer", package: "LookinServer")
      ],
      path: packageName,
      exclude: [
        "Assets.xcassets",
        "ThoughtStream.entitlements",
        "Info.plist"
      ]
    )
  ]
)