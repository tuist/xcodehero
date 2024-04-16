// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,] 
        productTypes: [
            "TSCclibc": .staticLibrary,
            "TSCLibc": .staticLibrary,
            "TSCBasic": .staticLibrary,
            "Path": .staticLibrary,
            "XcodeProj": .staticLibrary,
            "Command": .staticLibrary,
            "SwiftTerminal": .staticLibrary
        ]
    )
#endif

let package = Package(
    name: "Xcodehero",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.3.1")),
        .package(url: "https://github.com/tuist/Path", .upToNextMajor(from: "0.2.0")),
        .package(url: "https://github.com/PerfectlySoft/Perfect-INIParser.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/tuist/XcodeProj", .upToNextMajor(from: "8.20.0")),
        .package(url: "https://github.com/tuist/Command", .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/tuist/SwiftTerminal", .upToNextMajor(from: "0.10.0")),
        .package(url: "https://github.com/cpisciotta/xcbeautify", .upToNextMajor(from: "2.1.0"))
    ]
)
