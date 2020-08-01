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
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", .upToNextMinor(from: "19.0.0"))
    ],
    targets: [
        .target(
            name: "ComposableRequest",
            dependencies: []
        ),
        .target(
            name: "ComposableRequestCrypto",
            dependencies: ["ComposableRequest", "KeychainSwift"]
        ),
        .testTarget(
            name: "ComposableRequestTests",
            dependencies: ["ComposableRequest", "ComposableRequestCrypto"]
        )
    ]
)
