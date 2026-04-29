// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Trimbly",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TrimbleCore",
            targets: ["TrimbleCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TrimbleCore",
            dependencies: [],
            path: "Trimble",
            exclude: [
                "Info.plist",
                "Assets.xcassets",
                "Preview Content",
                "TrimbleApp.swift"
            ]
        )
    ]
)
