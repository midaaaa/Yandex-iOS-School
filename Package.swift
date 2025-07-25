// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Finance Tamer",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Finance Tamer",
            targets: ["Finance Tamer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Finance Tamer",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
            ],
            path: "Finance Tamer"
        ),
        .testTarget(
            name: "Finance TamerTests",
            dependencies: ["Finance Tamer"],
            dependencies: ["Finance Tamer"]
        ),
    ]
)
