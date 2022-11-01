//
//  Query.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` describing an instance providing the query items of a `URLRequest`.
///
/// - note:
///     When dealing with `String` dictionaries, instead of `URLQueryItem`s, all
///     keys are expected to be **unique**, repeated values will be overwritten.
public protocol ProtocolQuery: ProtocolPath { }

public extension ProtocolQuery {
    /// Copy `self` and replace its `query`.
    ///
    /// - parameter query: A valid `URLQueryItem` collection.
    /// - returns: A valid `Self`.
    func query<C>(_ query: C) -> Self where C: Collection, C.Element == URLQueryItem {
        var components = self.components
        components?.queryItems = query.isEmpty ? nil : Array(query)
        return self.components(components)
    }

    /// Copy `self` and replace its `query`.
    ///
    /// - parameter query: A valid `String` dictionary.
    /// - returns: A valid `Self`.
    func query(_ query: [String: String]) -> Self {
        self.query(query.map(URLQueryItem.init))
    }

    /// Copy `self` and replace its `query`.
    ///
    /// - parameter query: An optional `String` dictionary.
    /// - returns: A valid `Self`.
    func query(_ query: [String: String?]) -> Self {
        self.query(query.compactMapValues { $0 })
    }

    /// Append `query`, as parameters, to current ones.
    ///
    /// - parameter query: A valid `URLQueryItem` collection.
    /// - returns: A valid `Self`.
    func query<C: Collection>(appending query: C) -> Self where C.Element == URLQueryItem {
        self.query((components?.queryItems ?? []) + query)
    }

    /// Append `query`, as parameters, to current ones.
    ///
    /// - parameter query: A valid `String` dictionary.
    /// - returns: A valid `Self`.
    func query(appending query: [String: String]) -> Self {
        self.query((self.components?.queryItems ?? [])
                    .reduce(into: [:]) { $0[$1.name] = $1.value }
                    .merging(query) { _, rhs in rhs })
    }

    /// Append `query`, as parameters, to current ones.
    ///
    /// - parameter query: An optional `String` dictionary.
    /// - returns: A valid`Self`.
    func query(appending query: [String: String?]) -> Self {
        self.query((self.components?.queryItems ?? [])
                    .reduce(into: [:]) { $0[$1.name] = $1.value }
                    .merging(query) { _, rhs in rhs })
    }

    /// Append `value`, as a parameter, to the current query.
    ///
    /// - parameters:
    ///     - value: An optional `String`.
    ///     - key: A valid `String`.
    /// - returns: A valid `Self`.
    func query(appending value: String?, forKey key: String) -> Self {
        query(appending: [key: value])
    }
}
