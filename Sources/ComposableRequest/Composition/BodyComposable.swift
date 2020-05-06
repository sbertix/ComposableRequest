//
//  BodyComposable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` representing a composable `URLRequest` body.
public protocol BodyComposable {
    /// Replace the current `httpBody` with `data`.
    /// - parameter data: An optional `Data`.
    func replace(body data: Data?) -> Self
}

public extension BodyComposable {
    /// Replace the current `httpBody` with a JSON-encoded `value`.
    /// - parameters
    ///     - value: `Any` value.
    ///     - serializationOptions: A set of `JSONSerialization.WritingOptions`.
    func replace(body value: Any, serializationOptions: JSONSerialization.WritingOptions) -> Self {
        return replace(body: try? JSONSerialization.data(withJSONObject: value,
                                                         options: serializationOptions))
    }
    
    /// Replace the current `httpBody` with body-encoded `parameters`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func replace(body parameters: [String: String?]) -> Self {
        return replace(body: parameters
            .compactMap { key, value in value.flatMap { "\(key)=\($0)" }}
            .joined(separator: "&")
            .data(using: .utf8)
        )
    }
}

/// A `protocol` representing a wrapped `BodyComposable`.
public protocol WrappedBodyComposable: BodyComposable {
    /// A valid `Body`.
    associatedtype Body: BodyComposable
    
    /// A valid `BodyComposable`.
    var bodyComposable: Body { get set }
}

public extension WrappedBodyComposable {
    /// Replace the current `httpBody` with `data`.
    /// - parameter data: An optional `Data`.
    func replace(body data: Data?) -> Self {
        return copy(self) { $0.bodyComposable = $0.bodyComposable.replace(body: data) }
    }
}
