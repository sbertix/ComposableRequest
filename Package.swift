// swift-tools-version:5.2

import Foundation
import PackageDescription

// MARK: Definitions

let package = Package(
    name: "ComposableRequest",
    // Supported versions.
    platforms: [.iOS("13.0"),
                .macOS("10.15"),
                .tvOS("13.0"),
                .watchOS("6.0")],
    // Exposed libraries.
    products: [.library(name: "Requests",
                        targets: ["ComposableRequest"]),
               .library(name: "Storage",
                        targets: ["ComposableStorage"]),
               .library(name: "StorageCrypto",
                        targets: ["ComposableStorageCrypto"])],
    // Package dependencies.
    dependencies: [.package(url: "https://github.com/kishikawakatsumi/KeychainAccess",
                            .upToNextMinor(from: "4.2.2"))],
    // All targets.
    targets: [.target(name: "ComposableRequest"),
              .target(name: "ComposableStorage",
                      dependencies: []),
              .target(name: "ComposableStorageCrypto",
                      dependencies: ["ComposableStorage", "KeychainAccess"]),
              .testTarget(name: "ComposableRequestTests",
                          dependencies: ["ComposableRequest", "ComposableStorage", "ComposableStorageCrypto"])]
)

if ProcessInfo.processInfo.environment["TARGETING_WATCHOS"] == "true" {
    // #workaround(xcodebuild -version 11.6, Test targets don’t work on watchOS.) @exempt(from: unicode)
    package.targets.removeAll(where: { $0.isTest })
}
