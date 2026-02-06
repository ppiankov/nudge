// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Nudge",
    platforms: [
        .macOS(.v14),
    ],
    targets: [
        .executableTarget(
            name: "Nudge",
            path: "Sources/Nudge",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "NudgeTests",
            dependencies: ["Nudge"],
            path: "Tests/NudgeTests"
        ),
    ]
)
