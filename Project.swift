import ProjectDescription

let project = Project(
    name: "xcodehero",
    targets: [
        .target(
            name: "XcodeHeroKit",
            destinations: .macOS,
            product: .staticLibrary,
            bundleId: "io.tuist.XcodeHeroKit",
            deploymentTargets: .macOS("14.0.0"),
            sources: ["Sources/XcodeHeroKit/**"],
            dependencies: [
                .external(name: "ArgumentParser"),
                .external(name: "Path"),
                .external(name: "INIParser"),
                .external(name: "SwiftTerminal"),
                .external(name: "XcodeProj"),
                .external(name: "Command"),
                .external(name: "XcbeautifyLib")
            ]
        ),
        .target(
            name: "XcodeHeroKitAcceptanceTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "io.tuist.XcodeHeroKitAcceptanceTests",
            deploymentTargets: .macOS("14.0.0"),
            sources: ["Tests/XcodeHeroKitAcceptanceTests/**"],
            dependencies: [
                .target(name: "XcodeHeroKit")
            ]
        ),
        .target(
            name: "xcodehero",
            destinations: .macOS,
            product: .commandLineTool,
            bundleId: "io.tuist.xcodehero",
            deploymentTargets: .macOS("14.0.0"),
            sources: ["Sources/xcodehero/**"],
            dependencies: [
                .target(name: "XcodeHeroKit")
            ]
        )
    ]
)
