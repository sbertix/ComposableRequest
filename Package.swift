// swift-tools-version:5.7

import Foundation
import PackageDescription

let package = Package(
    name: "ComposableRequest",
    // Supported versions.
    platforms: [
        .iOS("13.0"),
        .macOS("10.15"),
        .tvOS("13.0"),
        .watchOS("6.0")
    ],
    // Exposed libraries.
    products: [
        .library(name: "Requests", targets: ["Requests"]),
        .library(name: "Storages", targets: ["Storages"]),
        .library(name: "EncryptedStorages", targets: ["EncryptedStorages"])
    ],
    // Package dependencies.
    dependencies: [
        .package(
            url: "https://github.com/kishikawakatsumi/KeychainAccess",
            .upToNextMinor(from: "4.2.2")
        )
    ],
    // All targets.
    targets: [
        .target(name: "Storages"),
        .target(name: "Requests", dependencies: ["Storages"]),
        .target(name: "EncryptedStorages", dependencies: ["Storages", "KeychainAccess"]),
        .testTarget(name: "ComposableRequestTests", dependencies: ["Requests", "Storages", "EncryptedStorages"])
    ]
)
