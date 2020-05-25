//
//  File.swift
//  
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` representing a composable `URLRequest` query.
public protocol QueryComposable {
    /// Replace the current `queryItems` with `parameters`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func replacing(query parameters: [String: String?]) -> Self
}

/// A `protocol` representing a `URLRequest` gettable query items.
public protocol QueryParsable {
    /// All `queryItems`.
    var query: [String: String] { get }
}

public extension QueryComposable where Self: QueryParsable {
    /// Append `parameters` to the current `queryItems`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func appending(query parameters: [String: String?]) -> Self {
        return replacing(query: parameters.merging(query) { lhs, _ in lhs })
    }

    /// Append matching `key` with `value` in the current `queryItems`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func appending(query key: String, with value: String?) -> Self {
        return appending(query: [key: value])
    }
}
