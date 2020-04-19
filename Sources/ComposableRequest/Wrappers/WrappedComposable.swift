//
//  WrappedComposable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `protocol` representing an item holding a reference to a composable `URLRequest`.
public protocol WrappedComposable: Composable {
    /// The underlying `Composable`.
    associatedtype Composable: ComposableRequest.Composable

    /// An underlying `Composable`.
    var composable: Composable { get set }
}

public extension WrappedComposable {
    /// Append `pathComponent`.
    /// - parameter pathComponent: A `String` representing a path component.
    func append(_ pathComponent: String) -> Self {
        return copy(self) { $0.composable = $0.composable.append(pathComponent) }
    }

    /// Append to `queryItems`. Empty `queryItems` if `nil`.
    /// - parameter method: A `Request.Method` value.
    func query(_ items: [String: String?]?) -> Self {
        return copy(self) { $0.composable = $0.composable.query(items) }
    }

    /// Set `method`.
    /// - parameter method: A `Request.Method` value.
    func method(_ method: Request.Method) -> Self {
        return copy(self) { $0.composable = $0.composable.method(method) }
    }

    /// Set `body`.
    /// - parameter body: A valid `Request.Body`.
    func body(_ body: Request.Body) -> Self {
        return copy(self) { $0.composable = $0.composable.body(body) }
    }

    /// Append to `Request.Body.parameters`. Empty `body` if `nil`.
    /// - parameter parameters: An optional `Dictionary` of  option`String`s.
    func body(_ parameters: [String: String?]?) -> Self {
        return copy(self) { $0.composable = $0.composable.body(parameters) }
    }

    /// Append to `header`. Empty `header` if `nil`.
    /// - parameter fields: An optional `Dictionary` of  option`String`s.
    func header(_ fields: [String: String?]?) -> Self {
        return copy(self) { $0.composable = $0.composable.header(fields) }
    }
}
