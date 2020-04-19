//
//  Composable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `protocol` representing a composable `URLRequest`.
@dynamicMemberLookup
public protocol Composable {
    /// Append `pathComponent`.
    /// - parameter pathComponent: A `String` representing a path component.
    func append(_ pathComponent: String) -> Self

    /// Append to `queryItems`. Empty `queryItems` if `nil`.
    /// - parameter method: A `Request.Method` value.
    func query(_ items: [String: String?]?) -> Self

    /// Set `method`.
    /// - parameter method: A `Request.Method` value.
    func method(_ method: Request.Method) -> Self

    /// Set `body`.
    /// - parameter body: A valid `Request.Body`.
    func body(_ body: Request.Body) -> Self

    /// Append to `Request.Body.parameters`. Empty `body` if `nil`.
    /// - parameter parameters: An optional `Dictionary` of  option`String`s.
    func body(_ parameters: [String: String?]?) -> Self

    /// Append to `header`. Empty `header` if `nil`.
    /// - parameter fields: An optional `Dictionary` of  option`String`s.
    func header(_ fields: [String: String?]?) -> Self
}

public extension Composable {
    /// Append `pathComponent`.
    /// - parameter pathComponent: A `String` representing a path component.
    subscript(dynamicMember pathComponent: String) -> Self {
        return append(pathComponent)
    }

    /// Append `pathComponent`.
    /// - parameter pathComponent: A `CustomStringConvertible` representing a path component.
    func append<PathComponent: CustomStringConvertible>(_ pathComponent: PathComponent) -> Self {
        return append(pathComponent.description)
    }

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

    /// Append to `Request.Body.parameters`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func body(_ key: String, value: String?) -> Self {
        return body([key: value])
    }

    /// Append to `header`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func header(_ key: String, value: String?) -> Self {
        return header([key: value])
    }
}
