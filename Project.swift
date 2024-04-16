import ProjectDescription

let project = Project(
    name: "xcodehero",
    targets: [
        .target(
            name: "xcodehero",
            destinations: .macOS,
            product: .commandLineTool,
            bundleId: "io.tuist.xcodehero",
            deploymentTargets: .macOS("14.0.0"),
            sources: ["xcodehero/Sources/**"],
            dependencies: [
                .external(name: "ArgumentParser"),
                .external(name: "Path"),
                .external(name: "INIParser"),
                .external(name: "SwiftTerminal"),
                .external(name: "XcodeProj"),
                .external(name: "Command"),
                .external(name: "XcbeautifyLib")
            ]
        )
    ]
)
