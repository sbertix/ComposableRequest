//
//  Cellular.swift
//  Requests
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining whether the request
/// for a given endpoint can run on cellular or not.
/// Defaults to `true`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Cellular: Component {
    /// The default value when no cached
    /// component can be found.
    public static var defaultValue: Cellular {
        .init(true)
    }

    /// A `Bool` representing whether the
    /// request can run on cellular or not.
    public let value: Bool

    /// Init.
    ///
    /// - parameter allowsCellularAccess: A `Bool` representing whether the request can run on cellular or not.
    public init(_ allowsCellularAccess: Bool) {
        self.value = allowsCellularAccess
    }

    /// Update a given `URLRequest`.
    ///
    /// - parameter request: A mutable `URLRequest`.
    public func update(_ request: inout URLRequest) {
        request.allowsCellularAccess = value
    }
}
