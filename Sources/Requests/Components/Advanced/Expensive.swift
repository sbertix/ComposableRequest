//
//  constrained.swift
//  Requests
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining whether the request
/// for a given endpoint is considered expensive.
/// Defaults to `true`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Expensive: Component {
    /// The default value when no cached
    /// component can be found.
    public static var defaultValue: Expensive {
        .init(true)
    }

    /// A `Bool` representing whether the request i's expensive to run.
    public let value: Bool

    /// Init.
    ///
    /// - parameter allowsExpensiveNetworkAccess: A `Bool` representing whether the request is expensive to run.
    public init(_ allowsExpensiveNetworkAccess: Bool) {
        self.value = allowsExpensiveNetworkAccess
    }

    /// Update a given `URLRequest`.
    ///
    /// - parameter request: A mutable `URLRequest`.
    public func update(_ request: inout URLRequest) {
        request.allowsExpensiveNetworkAccess = value
    }
}
