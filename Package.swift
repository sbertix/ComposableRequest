// swift-tools-version:5.7

import Foundation
import PackageDescription

let package = Package(
    name: "ComposableRequest",
    // Supported versions.
    platforms: [.iOS("13.0"),
                .macOS("10.14"),
                .tvOS("12.0"),
                .watchOS("5.0")],
    // Exposed libraries.
    products: [.library(name: "Requests",
                        targets: ["Requests"]),
               .library(name: "Storages",
                        targets: ["Storages"]),
               .library(name: "EncryptedStorages",
                        targets: ["EncryptedStorages"])],
    // Package dependencies.
    dependencies: [.package(url: "https://github.com/kishikawakatsumi/KeychainAccess",
                            .upToNextMinor(from: "4.2.2")),
                   .package(url: "https://github.com/kean/Future",
                            .upToNextMinor(from: "1.4.0"))],
    // All targets.
    targets: [.target(name: "Core"),
              .target(name: "Requests",
                      dependencies: ["Core", "Future"]),
              .target(name: "Storages",
                      dependencies: []),
              .target(name: "EncryptedStorages",
                      dependencies: ["Storages", "KeychainAccess"]),
              .testTarget(name: "ComposableRequestTests",
                          dependencies: ["Requests", "Storages", "EncryptedStorages"])]
)

if ProcessInfo.processInfo.environment["TARGETING_WATCHOS"] == "true" {
    // #workaround(xcodebuild -version 11.6, Test targets don’t work on watchOS.) @exempt(from: unicode)
    package.targets.removeAll(where: { $0.isTest })
}
