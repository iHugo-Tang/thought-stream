// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "ThoughtStream",
    dependencies: [
        .package(url: "https://github.com/JakubMazur/lucide-icons-swift", from: "0.542.0"),
        .package(url: "https://github.com/QMUI/LookinServer", from: "1.2.8"),
    ]
)
