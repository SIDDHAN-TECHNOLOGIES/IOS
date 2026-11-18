// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DynamicIsland-iPhone13",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "DynamicIsland-iPhone13",
            targets: ["DynamicIsland-iPhone13"]
        ),
    ],
    targets: [
        .target(
            name: "DynamicIsland-iPhone13",
            path: "."
        ),
    ]
)
