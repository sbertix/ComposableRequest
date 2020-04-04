// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "ComposableRequest",
    products: [
        .library(
            name: "ComposableRequest",
            targets: ["ComposableRequest"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ComposableRequest",
            dependencies: []),
        .testTarget(
            name: "ComposableRequestTests",
            dependencies: ["ComposableRequest"])
    ]
)
