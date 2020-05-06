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
        return append(query: parameters.map { URLQueryItem(name: $0.key, value: $0.value) })
    }
    
    /// Append matching `key` with `value` in the current `queryItems`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func append(query key: String, with value: String?) -> Self {
        return append(query: [key: value])
    }
    
    /// Replace the current `queryItems` with `parameters`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func replace(query parameters: [String: String?]) -> Self {
        return replace(query: parameters.map { URLQueryItem(name: $0.key, value: $0.value) })
    }
    
    /// Replace matching `key` with `value` in the current `queryItems`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func replace(query key: String, with value: String?) -> Self {
        return replace(query: [key: value])
    }
}
