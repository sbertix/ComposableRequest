//
//  File.swift
//  
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` representing a composable `URLRequest` query.
public protocol QueryComposable {
    /// Append `items` to the current `queryItems`.
    /// - parameter items: A `Collection` of `URLQueryItem`s.
    func append<C: Collection>(query items: C) -> Self where C.Element == URLQueryItem
    
    /// Replace the current `queryItems` with `items`.
    /// - parameter items: A `Collection` of `URLQueryItem`s.
    func replace<C: Collection>(query items: C) -> Self where C.Element == URLQueryItem
}

public extension QueryComposable {
    /// Append `parameters` to the current `queryItems`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func append(query parameters: [String: String?]) -> Self {
        return append(query: parameters.compactMap { key, value in
            value.flatMap { URLQueryItem(name: key, value: $0) }
        })
    }
    
    /// Replace the current `queryItems` with `parameters`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func replace(query parameters: [String: String?]) -> Self {
        return replace(query: parameters.compactMap { key, value in
            value.flatMap { URLQueryItem(name: key, value: $0) }
        })
    }
    
    /// Replace matching `key` with `value` in the current `queryItems`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func replace(query key: String, with value: String?) -> Self {
        return replace(query: [key: value])
    }
}

/// A `protocol` representing a wrapped `QueryComposable`.
public protocol WrappedQueryComposable: QueryComposable {
    /// A valid `Query`.
    associatedtype Query: QueryComposable
    
    /// A valid `QueryComposable`.
    var queryComposable: Query { get set }
}

public extension WrappedQueryComposable {
    /// Append `items` to the current `queryItems`.
    /// - parameter items: A `Collection` of `URLQueryItem`s.
    func append<C: Collection>(query items: C) -> Self where C.Element == URLQueryItem {
        return copy(self) { $0.queryComposable = $0.queryComposable.append(query: items) }
    }
    
    /// Replace the current `queryItems` with `items`.
    /// - parameter items: A `Collection` of `URLQueryItem`s.
    func replace<C: Collection>(query items: C) -> Self where C.Element == URLQueryItem {
        return copy(self) { $0.queryComposable = $0.queryComposable.replace(query: items) }
    }
}
