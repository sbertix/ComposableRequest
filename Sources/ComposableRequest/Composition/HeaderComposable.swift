//
//  HeaderComposable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` representing a composable `URLRequest` header fields.
public protocol HeaderComposable {
    /// Replace the current `allHTTPHeaderFields` with `parameters`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func replacing(header parameters: [String: String?]) -> Self
}

/// A `protocol` representing a `URLRequest` gettable header fields.
public protocol HeaderParsable {
    /// Return `allHTTPHeaderFields`.
    var header: [String: String] { get }
}

public extension HeaderComposable {
    /// Replace matching `key` with `value` in the current `allHTTPHeaderFields`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func replacing(header key: String, with value: String?) -> Self {
        return replacing(header: [key: value])
    }
}

public extension HeaderComposable where Self: HeaderParsable {
    /// Append `parameters` to the current `allHTTPHeaderFields`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func appending(header parameters: [String: String?]) -> Self {
        return replacing(header: parameters.merging(header) { lhs, _ in lhs })
    }

    /// Append `key` and `value` to the current `allHTTPHeaderFields`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func appending(header key: String, with value: String?) -> Self {
        return appending(header: [key: value])
    }
}
