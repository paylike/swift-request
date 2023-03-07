// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PaylikeRequest",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "PaylikeRequest", targets: ["PaylikeRequest"]),
    ],
    dependencies: [
        .package(url: "git@github.com:httpswift/swifter.git", .upToNextMajor(from: "1.5.0"))
    ],
    targets: [
        .target(name: "PaylikeRequest", dependencies: []),
        .testTarget(
            name: "PaylikeRequestTests",
            dependencies: [
                "PaylikeRequest",
                .product(name: "Swifter", package: "swifter")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
