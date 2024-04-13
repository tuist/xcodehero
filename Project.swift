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
            dependencies: []
        )
    ]
)
