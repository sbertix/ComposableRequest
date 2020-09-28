// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "ComposableRequest",
    products: [
        .library(
            name: "ComposableRequest",
            targets: ["ComposableRequest"]),
        .library(
            name: "ComposableRequestCrypto",
            targets: ["ComposableRequestCrypto"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sbertix/Swiftchain.git", .upToNextMinor(from: "0.0.1"))
    ],
    targets: [
        .target(
            name: "ComposableRequest",
            dependencies: []
        ),
        .target(
            name: "ComposableRequestCrypto",
            dependencies: ["ComposableRequest", "Swiftchain"]
        ),
        .testTarget(
            name: "ComposableRequestTests",
            dependencies: ["ComposableRequest", "ComposableRequestCrypto"]
        )
    ]
)
