//
//  File.swift
//  
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` representing a composable `URLRequest` query.
public protocol QueryComposable {
    /// Append to `queryItems`. Empty `queryItems` if `nil`.
    /// - parameter method: A `Request.Method` value.
    func query(_ items: [String: String?]?) -> Self
}

public extension QueryComposable {
    /// Set `queryItems`.
    /// - parameter items: An `Array` of `URLQueryItem`s.
    func query(_ items: [URLQueryItem]) -> Self {
        return query(nil)
            .query(Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value) }))
    }

    /// Append to `queryItems`.
    /// - parameters:
    ///     - key: A `String` representing a `URLQueryItem.name`.
    ///     - value: An optional `String` representing a `URLQueryItem.value`.
    func query(_ key: String, value: String?) -> Self {
        return query([key: value])
    }
}
