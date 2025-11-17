import ProjectDescription

let project = Project(
    name: "ThoughtStream",
    targets: [
        .target(
            name: "ThoughtStream",
            destinations: .iOS,
            product: .app,
            bundleId: "cc.ihugo.practice.ThoughtStream",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ]
                ]
            ),
            buildableFolders: [
                "./Sources",
                "./Resources",
            ],
            dependencies: [
                .external(name: "LookinServer"),
                .external(name: "LucideIcons"),
            ]
        ),
        .target(
            name: "ThoughtStreamTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "cc.ihugo.practice.ThoughtStreamTests",
            infoPlist: .default,
            buildableFolders: [
                "ThoughtStream/Tests"
            ],
            dependencies: [.target(name: "ThoughtStream")]
        ),
    ],
    resourceSynthesizers: [.assets()],
)
