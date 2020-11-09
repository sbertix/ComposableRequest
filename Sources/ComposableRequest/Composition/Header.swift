//
//  Header.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` describing an instance providing the header fields of a `URLRequest`.
public protocol Header {
    /// The underlying header fields.
    var header: [String: String] { get set }
}

public extension Header {
    /// Copy `self` and replace its `header`.
    ///
    /// - parameter header: Some dictionary of `String`s.
    /// - returns: A copy of `self`.
    func header(_ header: [String: String]) -> Self {
        var copy = self
        copy.header = header
        return copy
    }

    /// Copy `self` and replace its `header`.
    ///
    /// - parameter header: Some dictionary of optional `String`s.
    /// - returns: A copy of `self`.
    func header(_ header: [String: String?]) -> Self {
        self.header(header.compactMapValues { $0 })
    }

    /// Copy `self` and replace its `header`.
    ///
    /// - parameters:
    ///     - value: A valid `String`.
    ///     - key: A valid `String`.
    /// - returns: A copy of `self`.
    func header(_ value: String, forKey key: String) -> Self {
        self.header([key: value])
    }
}

public extension Header {
    /// Append `header`, as parameters, to current ones.
    ///
    /// - parameter header: Some dictionary of `String`s.
    /// - returns: A copy of `self`.
    func header(appending header: [String: String]) -> Self {
        self.header(self.header.merging(header) { _, rhs in rhs })
    }

    /// Append `header`, as parameters, to current ones.
    ///
    /// - parameter header: Some dictionary of optional `String`s.
    /// - returns: A copy of `self`.
    func header(appending header: [String: String?]) -> Self {
        var copy = self
        header.forEach { copy.header[$0] = $1 }
        return copy
    }

    /// Append `value`, as a parameter, to the current header.
    ///
    /// - parameters:
    ///     - value: A valid `String`.
    ///     - key: A valid `String`.
    /// - returns: A copy of `self`.
    func header(appending value: String, forKey key: String) -> Self {
        header(appending: [key: value])
    }
}
