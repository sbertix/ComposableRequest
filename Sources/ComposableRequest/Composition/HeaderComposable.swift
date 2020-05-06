//
//  HeaderComposable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` representing a composable `URLRequest` header fields.
public protocol HeaderComposable {
    /// Append `parameters` to the current `allHTTPHeaderFields`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func append(header parameters: [String: String?]) -> Self
    
    /// Replace the current `allHTTPHeaderFields` with `parameters`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func replace(header parameters: [String: String?]) -> Self
}

public extension HeaderComposable {
    /// Append `key` and `value` to the current `allHTTPHeaderFields`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func append(header key: String, with value: String?) -> Self {
        return append(header: [key: value])
    }
    
    /// Replace matching `key` with `value` in the current `allHTTPHeaderFields`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    func replace(header key: String, with value: String?) -> Self {
        return replace(header: [key: value])
    }
}
