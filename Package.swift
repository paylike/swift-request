// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PaylikeRequest",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PaylikeRequest",
            targets: ["PaylikeRequest"]),
    ],
    dependencies: [
        .package(url: "git@github.com:httpswift/swifter.git", .upToNextMajor(from: "1.5.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PaylikeRequest",
            dependencies: []),
        .testTarget(
            name: "PaylikeRequestTests",
            dependencies: ["PaylikeRequest", .product(name: "Swifter", package: "swifter")]),
    ]
)
