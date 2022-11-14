//
//  Constrained.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining whether the request
/// for a given endpoint should run on a constrained
/// network.
/// Defaults to `true`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Constrained: Component {
    /// The default value when no cached
    /// component can be found.
    public static var defaultValue: Constrained {
        .init(true)
    }

    /// A `Bool` representing whether it can run on constrained networks or not.
    public let value: Bool

    /// Init.
    ///
    /// - parameter allowsconstrained: A `Bool` representing whether it can run on constrained networks or not.
    public init(_ allowsconstrained: Bool) {
        self.value = allowsconstrained
    }

    /// Update a given `URLRequest`.
    ///
    /// - parameter request: A mutable `URLRequest`.
    public func update(_ request: inout URLRequest) {
        request.allowsConstrainedNetworkAccess = value
    }
}
