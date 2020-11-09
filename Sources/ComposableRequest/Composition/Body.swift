//
//  Body.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` describing an instance providing the body of a `URLRequest`.
public protocol Body {
    /// The underlying request body.
    var body: Data? { get set }
}

public extension Body {
    /// Copy `self` and replace its `body`.
    ///
    /// - parameter body: Some optional `Data`.
    /// - returns: A copy of `self`.
    func body(_ body: Data?) -> Self {
        var copy = self
        copy.body = body
        return copy
    }

    /// Copy `self` and replace its `body` with a JSON representation of a `Wrappable` element.
    ///
    /// - parameter body: A valid `Wrappable`.
    /// - returns: A copy of `self`.
    /// - throws: Some encoding-related `Error`.
    func body<W: Wrappable>(_ body: W) throws -> Self {
        self.body(try body.wrapped.encode())
    }

    /// Copy `self` and replace its `body`, as parameters.
    ///
    /// A dictionary like `["key1": "value1", "key2": "value2"]`
    /// converts into the data representation of a `String` like
    /// `key1=value1&key2=value2`.
    ///
    /// - parameter body: Some dictionary of `String`.
    /// - returns: A copy of `self`.
    func body(_ body: [String: String]) -> Self {
        self.body(body.encoded)
    }

    /// Copy `self` and replace its `body`.
    ///
    /// - parameters:
    ///     - value: A valid `String`.
    ///     - key: A valid `String`.
    /// - returns: A copy of `self`.
    func body(_ value: String, forKey key: String) -> Self {
        self.body([key: value])
    }
}

public extension Body {
    /// Append `body`, as parameters, to current one, if valid.
    /// Replace them otherwise.
    ///
    /// - parameter body: Some dictionary of `String`.
    /// - returns: A copy of `self`.
    func body(appending body: [String: String]) -> Self {
        self.body(self.body?.parameters?.merging(body) { _, rhs in rhs } ?? body)
    }

    /// Append `value`, as a parameter, to the current body, if valid.
    /// Replace it otherwise.
    ///
    /// - parameters:
    ///     - value: A valid `String`.
    ///     - key: A valid `String`.
    /// - returns: A copy of `self`.
    func body(appending value: String, forKey key: String) -> Self {
        body(appending: [key: value])
    }
}
