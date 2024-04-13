import ProjectDescription

let project = Project(
    name: "Xcodehero",
    targets: [
        .target(
            name: "Xcodehero",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Xcodehero",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["Xcodehero/Sources/**"],
            resources: ["Xcodehero/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "XcodeheroTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.XcodeheroTests",
            infoPlist: .default,
            sources: ["Xcodehero/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Xcodehero")]
        ),
    ]
)
