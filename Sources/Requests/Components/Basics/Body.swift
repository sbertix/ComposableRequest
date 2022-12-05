//
//  Body.swift
//  Requests
//
//  Created by Stefano Bertagno on 01/11/22.
//

#if canImport(Combine)
import protocol Combine.TopLevelEncoder
#endif

import Foundation

/// A `struct` defining the request body for a given endpoint.
/// Defaults to `nil`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Body: Component {
    /// The default value when no cached
    /// component can be found.
    public static var defaultValue: Body {
        .init(nil)
    }

    /// The request body for a given endpoint.
    public let value: Data?

    /// Init.
    ///
    /// - parameter body: The request body for a given endpoint.
    public init(_ body: Data?) {
        self.value = body
    }

    /// Init.
    ///
    /// - parameters:
    ///     - body: Some `Encodable` instance.
    ///     - encoder: A valid `JSONEncoder`. Defaults to `.init`.
    public init(_ body: some Encodable, encoder: JSONEncoder = .init()) {
        self.init(try? encoder.encode(body))
    }

    /// Init.
    ///
    /// A dictionary like `["key1": "value1", "key2": "value2"]`
    /// converts into the data representation of a `String` like
    /// `key1=value1&key2=value2`.
    ///
    /// - parameter body: The request body parameters for a given endpoint.
    public init(parameters body: [String: String]) {
        self.init(body.encoded)
    }

    /// Init.
    ///
    /// A dictionary like `["key1": "value1", "key2": "value2"]`
    /// converts into the data representation of a `String` like
    /// `key1=value1&key2=value2`.
    ///
    /// - parameter body: The request body parameters for a given endpoint.
    public init(parameters body: [String: String?]) {
        self.init(body.compactMapValues { $0 }.encoded)
    }

    #if canImport(Combine)
    /// Init.
    ///
    /// - parameters:
    ///     - body: Some `Encodable`.
    ///     - encoder: Some `TopLevelEncoder`.
    public init<E: TopLevelEncoder>(_ body: some Encodable, encoder: E) where E.Output == Data {
        self.init(try? encoder.encode(body))
    }
    #endif

    /// Update a given `URLRequest`.
    ///
    /// - parameter request: A mutable `URLRequest`.
    public func update(_ request: inout URLRequest) {
        request.httpBody = value
    }
}
