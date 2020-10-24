// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "ComposableRequest",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
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
        .package(url: "https://github.com/sbertix/Swiftchain.git", .upToNextMinor(from: "1.0.0"))
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
