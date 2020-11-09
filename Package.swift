// swift-tools-version:5.2

import Foundation
import PackageDescription

// MARK: Definitions

let package = Package(
    name: "ComposableRequest",
    // Supported versions.
    platforms: [.iOS(.v9),
                .macOS(.v10_10),
                .tvOS(.v9),
                .watchOS(.v2)],
    // Exposed libraries.
    products: [.library(name: "ComposableRequest",
                        targets: ["ComposableRequest"]),
               .library(name: "ComposableStorage",
                        targets: ["ComposableStorage"]),
               .library(name: "ComposableStorageCrypto",
                        targets: ["ComposableStorageCrypto"])],
    // Package dependencies.
    dependencies: [.package(url: "https://github.com/cx-org/CombineX",
                            .upToNextMinor(from: "0.3.0")),
                   .package(url: "https://github.com/sbertix/Swiftchain.git",
                            .upToNextMinor(from: "1.0.0"))],
    // All targets.
    targets: [.target(name: "ComposableRequest",
                      dependencies: [.product(name: "CXShim", package: "CombineX")]),
              .target(name: "ComposableStorage",
                      dependencies: []),
              .target(name: "ComposableStorageCrypto",
                      dependencies: ["ComposableStorage", "Swiftchain"]),
              .testTarget(name: "ComposableRequestTests",
                          dependencies: ["ComposableRequest", "ComposableStorage", "ComposableStorageCrypto"])]
)

enum CombineImplementation {
    /// Apple **Combine**.
    case combine
    /// **cx-org/CombineX**.
    case combineX
    
    /// Default implementation.
    /// If available, Apple **Combine** is always preferred.
    static var `default`: CombineImplementation {
        #if canImport(Combine)
        return .combine
        #else
        return .combineX
        #endif
    }
    
    /// Optional init.
    ///
    /// - parameter description: A valid `String`.
    init?(_ description: String) {
        let desc = description.lowercased().filter { $0.isLetter }
        switch desc {
        case "combine": self = .combine
        case "combinex": self = .combineX
        default: return nil
        }
    }
}

extension ProcessInfo {
    /// The selected combine implementation. Defaults to `.default`.
    var combineImplementation: CombineImplementation {
        return environment["CX_COMBINE_IMPLEMENTATION"].flatMap(CombineImplementation.init) ?? .default
    }
}

// MARK: Adjustments

if ProcessInfo.processInfo.environment["TARGETING_WATCHOS"] == "true" {
    // #workaround(xcodebuild -version 11.6, Test targets don’t work on watchOS.) @exempt(from: unicode)
    package.targets.removeAll(where: { $0.isTest })
}
if ProcessInfo.processInfo.combineImplementation == .combine {
    package.platforms = [.macOS("10.15"), .iOS("13.0"), .tvOS("13.0"), .watchOS("6.0")]
}
