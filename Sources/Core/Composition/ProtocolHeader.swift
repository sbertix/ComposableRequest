//
//  Header.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` describing an instance providing the header fields of a `URLRequest`.
public protocol ProtocolHeader {
    /// The current header fields.
    var header: [String: String] { get }

    /// Copy `self` and replace its `header`.
    ///
    /// - parameter header: A valid`String` dictionary.
    /// - returns: A valid `Self`.
    func header(_ header: [String: String]) -> Self
}

public extension ProtocolHeader {
    /// Copy `self` and replace its `header`.
    ///
    /// - parameter header: An optional `String` dictionary.
    /// - returns: A valid `Self`.
    func header(_ header: [String: String?]) -> Self {
        self.header(header.compactMapValues { $0 })
    }

    /// Copy `self` and replace its `header`.
    ///
    /// - parameters:
    ///     - value: An optional `String`.
    ///     - key: A valid `String`.
    /// - returns: A valid `Self`.
    func header(_ value: String?, forKey key: String) -> Self {
        self.header([key: value])
    }

    /// Append `header`, as parameters, to current ones.
    ///
    /// - parameter header: A valid `String` dictionary.
    /// - returns: A valid `Self`.
    func header(appending header: [String: String]) -> Self {
        self.header(self.header.merging(header) { _, rhs in rhs })
    }

    /// Append `header`, as parameters, to current ones.
    ///
    /// - parameter header: An optional `String` dictionary.
    /// - returns: A valid `Self`.
    func header(appending header: [String: String?]) -> Self {
        var current = self.header
        header.forEach { current[$0] = $1 }
        return self.header(current)
    }

    /// Append `value`, as a parameter, to the current header.
    ///
    /// - parameters:
    ///     - value: An optional `String`.
    ///     - key: A valid `String`.
    /// - returns: A copy of `self`.
    func header(appending value: String?, forKey key: String) -> Self {
        header(appending: [key: value])
    }
}
