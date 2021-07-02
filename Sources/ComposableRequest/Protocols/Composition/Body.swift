//
//  Body.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` describing an instance providing the body of a `URLRequest`.
public protocol Body {
    /// The current body.
    var body: Data? { get }

    /// Copy `self` and replace its `body`.
    ///
    /// - parameter body: Some optional `Data`.
    /// - returns: A valid `Self`.
    func body(_ body: Data?) -> Self
}

public extension Body {
    /// Copy `self` and replace its `body` with a JSON representation of a `Wrappable` element.
    ///
    /// - parameter body: A concrete instance of `Wrappable`.
    /// - throws: Some encoding-related `Error`.
    /// - returns: A valid `Self`.
    func body<W: Wrappable>(_ body: W) throws -> Self {
        self.body(try body.wrapped.encode())
    }

    /// Copy `self` and replace its `body` with a dictionary based representation.
    ///
    /// A dictionary like `["key1": "value1", "key2": "value2"]`
    /// converts into the data representation of a `String` like
    /// `key1=value1&key2=value2`.
    ///
    /// - parameter body: A valid `String` dictionary.
    /// - returns: A valid `Self`.
    func body(_ body: [String: String]) -> Self {
        self.body(body.encoded)
    }

    /// Copy `self` and replace its `body` with a dictionary based representation,
    /// consisting of a single pair `["key": "value"]`.
    ///
    /// - parameters:
    ///     - value: A valid `String`.
    ///     - key: A valid `String`.
    /// - returns: A valid `Self`.
    func body(_ value: String, forKey key: String) -> Self {
        body([key: value])
    }

    /// Append `body`, as parameters, to the current one, if valid.
    /// Replace them otherwise.
    ///
    /// - parameter body: A valid `String` dictionary.
    /// - returns: A valid `Self`.
    func body(appending body: [String: String]) -> Self {
        self.body(self.body?.parameters?.merging(body) { _, rhs in rhs } ?? body)
    }

    /// Append `value`, as a parameter, to the current body, if valid.
    /// Replace it otherwise.
    ///
    /// - parameters:
    ///     - value: A valid `String`.
    ///     - key: A valid `String`.
    /// - returns: A valid `Self`.
    func body(appending value: String, forKey key: String) -> Self {
        body(appending: [key: value])
    }
}
