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
    func appending<C: Collection>(query items: C) -> Self where C.Element == URLQueryItem

    /// Replace the current `queryItems` with `items`.
    /// - parameter items: A `Collection` of `URLQueryItem`s.
    func replacing<C: Collection>(query items: C) -> Self where C.Element == URLQueryItem
}

public extension QueryComposable {
    /// Append `parameters` to the current `queryItems`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func appending(query parameters: [String: String?]) -> Self {
        return appending(query: parameters.map { URLQueryItem(name: $0.key, value: $0.value) })
    }

    /// Append matching `key` with `value` in the current `queryItems`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func appending(query key: String, with value: String?) -> Self {
        return appending(query: [key: value])
    }

    /// Replace the current `queryItems` with `parameters`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func replacing(query parameters: [String: String?]) -> Self {
        return replacing(query: parameters.map { URLQueryItem(name: $0.key, value: $0.value) })
    }
}
