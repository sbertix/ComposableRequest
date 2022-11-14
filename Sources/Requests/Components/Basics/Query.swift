//
//  Query.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the query
/// items for a given endpoint.
/// Defaults to empty.
public struct Query: Component {
    /// The default value when no cached
    /// component can be found.
    public static var defaultValue: Query {
        .init([])
    }

    /// The query items for a given endpoint.
    public let value: [URLQueryItem]

    /// Init.
    ///
    /// - parameter items: The query items for a given endpoint.
    public init<C: Sequence>(_ items: C) where C.Element == URLQueryItem {
        self.value = .init(items)
    }

    /// Init.
    ///
    /// - parameter query: The query items for a given endpoint.
    /// - note: `nil`-valued items will still be added to the query to allow for flags, switches, etc.
    public init(withFlags query: [String: String?]) {
        self.value = query.map(URLQueryItem.init)
    }

    /// Init.
    ///
    /// - parameter query: The query items for a given endpoint.
    /// - note: `nil`-valued items will be discarded.
    public init(_ query: [String: String?]) {
        self.init(withFlags: query.compactMapValues { $0 })
    }

    /// Init.
    ///
    /// - parameter query: The query items for a given endpoint.
    public init(_ query: [String: String]) {
        self.init(withFlags: query)
    }

    /// Init.
    ///
    /// - parameters:
    ///     - value: A `String` representing a single query item value.
    ///     - key: A `String` representing a single query item key.
    public init(_ value: String, forKey key: String) {
        self.init(withFlags: [key: value])
    }

    /// Init.
    ///
    /// - parameters:
    ///     - value: An optional `String` representing a single query item value. `nil` will be ignored.
    ///     - key: A `String` representing a single query item key.
    public init(_ value: String?, forKey key: String) {
        self.init(withFlags: value.flatMap { [key: $0] } ?? [:])
    }

    /// Update a given `URLRequest`.
    ///
    /// - parameter request: A mutable `URLRequest`.
    public func update(_ request: inout URLRequest) {
        // `Query` has already been
        // set at this point.
    }
}
