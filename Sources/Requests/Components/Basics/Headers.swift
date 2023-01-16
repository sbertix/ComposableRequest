//
//  Headers.swift
//  Requests
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the request
/// headers for a given endpoint.
/// Defaults to empty.
public struct Headers: Component {
    /// The default value when no cached
    /// component can be found.
    public static var defaultValue: Headers {
        .init([:])
    }

    /// The request headers for a given endpoint.
    public var value: [String: String]

    /// Init.
    ///
    /// - parameter headers: The request headers for a given endpoint.
    public init(_ headers: [String: String]) {
        self.value = headers
    }

    /// Init.
    ///
    /// - parameter headers: The request headers for a given endpoint.
    public init(_ headers: [String: String?]) {
        self.init(headers.compactMapValues { $0 })
    }

    /// Init.
    ///
    /// - parameters:
    ///     - value: A `String` representing a single request header value.
    ///     - key: A `String` representing a single request header key.
    public init(_ value: String, forKey key: String) {
        self.init([key: value])
    }

    /// Init.
    ///
    /// - parameters:
    ///     - value: An optional `String` representing a single request header value. `nil` will be ignored.
    ///     - key: A `String` representing a single request header key.
    public init(_ value: String?, forKey key: String) {
        self.init(value.flatMap { [key: $0] } ?? [:])
    }

    /// Init.
    ///
    /// - parameters uniqueKeysAndValues: A sequence of unique `String` tuples of request header keys and values.
    public init<C: Sequence>(_ keysAndValues: C) where C.Element == (String, String) {
        self.init(.init(uniqueKeysWithValues: keysAndValues))
    }

    /// Init.
    ///
    /// - parameters:
    ///     - keys: A sequence of unique `String`s representing request header keys.
    ///     - values: A sequence of `String`s representing request header values.
    public init<K: Sequence, V: Sequence>(keys: K, values: V) where K.Element == String, V.Element == String {
        self.init(zip(keys, values))
    }

    /// Inherit some previously cached value.
    ///
    /// ```
    /// Headers("value1", forKey: "key1")
    /// Headers("value2", forKey: "key2")
    /// ```
    /// would be resolved to `["key1": "value1", "key2": "value2"]`.
    ///
    /// - note:
    ///     If there's no cached value, this will not be called,
    ///     instead the new one will replace the default one.
    /// - parameter original: The original value for the cached component.
    public mutating func inherit(from original: any Component) {
        guard let original = original as? Headers else { return }
        value.merge(original.value) { lhs, _ in lhs }
    }

    /// Update a given `URLRequest`.
    ///
    /// - parameter request: A mutable `URLRequest`.
    public func update(_ request: inout URLRequest) {
        request.allHTTPHeaderFields = value
    }
}
