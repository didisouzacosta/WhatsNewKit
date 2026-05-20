// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WhatsNewKit",
    platforms: [
        .iOS("18.6"),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "WhatsNewKit",
            targets: ["WhatsNewKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.9.0")
    ],
    targets: [
        .target(
            name: "WhatsNewKit",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher")
            ]
        ),
        .testTarget(
            name: "WhatsNewKitTests",
            dependencies: ["WhatsNewKit"]
        )
    ]
)
