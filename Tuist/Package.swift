// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,] 
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Xcodehero",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.3.1")),
        .package(url: "https://github.com/tuist/Path", .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/PerfectlySoft/Perfect-INIParser.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/tuist/SwiftTerminal", .revisionItem("1dca7323df4aaba743a4383e8dec76112feabd16")),
        .package(url: "https://github.com/tuist/XcodeProj", .upToNextMajor(from: "8.20.0"))
    ]
)
