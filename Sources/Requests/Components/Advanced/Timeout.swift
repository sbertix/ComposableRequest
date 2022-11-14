//
//  Timeout.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining when the request
/// for a given endpoint can timeout.
/// Defaults to `60`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Timeout: Component {
    /// The default value when no cached
    /// component can be found.
    public static var defaultValue: Timeout {
        .init(60)
    }

    /// The time before the request times out.
    public let value: TimeInterval

    /// Init.
    ///
    /// - parameter timeoutInterval: A `TimeInterval` representing the time before the request times out.
    public init(_ timeoutInterval: TimeInterval) {
        self.value = timeoutInterval
    }

    /// Update a given `URLRequest`.
    ///
    /// - parameter request: A mutable `URLRequest`.
    public func update(_ request: inout URLRequest) {
        request.timeoutInterval = value
    }
}
