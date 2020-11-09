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
public protocol Query {
    /// The underlying request url components.
    var components: URLComponents? { get set }
}

public extension Query {
    /// Copy `self` and replace its `query`.
    ///
    /// - parameter query: A collection of `URLQueryItem`s.
    /// - returns: A copy of `self`.
    func query<C: Collection>(_ query: C) -> Self where C.Element == URLQueryItem {
        var copy = self
        copy.components?.queryItems = query.isEmpty ? nil : Array(query)
        return copy
    }

    /// Copy `self` and replace its `query`.
    ///
    /// - parameter query: A dictionary of `String`s.
    /// - returns: A copy of `self`.
    func query(_ query: [String: String]) -> Self {
        self.query(query.map(URLQueryItem.init))
    }

    /// Copy `self` and replace its `query`.
    ///
    /// - parameter query: A dictionary of optional `String`s.
    /// - returns: A copy of `self`.
    func query(_ query: [String: String?]) -> Self {
        self.query(query.compactMapValues { $0 })
    }
}

public extension Query {
    /// Append `query`, as parameters, to current ones.
    ///
    /// - parameter query: A collection of `URLQueryItem`s.
    /// - returns: A copy of `self`.
    func query<C: Collection>(appending query: C) -> Self where C.Element == URLQueryItem {
        self.query((components?.queryItems ?? [])+query)
    }

    /// Append `query`, as parameters, to current ones.
    ///
    /// - parameter query: Some dictionary of `String`s.
    /// - returns: A copy of `self`.
    func query(appending query: [String: String]) -> Self {
        self.query((self.components?.queryItems ?? [])
                    .reduce(into: [:]) { $0[$1.name] = $1.value }
                    .merging(query) { _, rhs in rhs })
    }

    /// Append `query`, as parameters, to current ones.
    ///
    /// - parameter query: A dictionary of optional `String`s.
    /// - returns: A copy of `self`.
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
    /// - returns: A copy of `self`.
    func query(appending value: String?, forKey key: String) -> Self {
        query(appending: [key: value])
    }
}
