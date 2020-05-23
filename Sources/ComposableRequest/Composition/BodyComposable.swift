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
    func replacing(body data: Data?) -> Self
}

public extension BodyComposable {
    /// Replace the current `httpBody` with a JSON-encoded `value`.
    /// - parameters
    ///     - value: `Any` value.
    ///     - serializationOptions: A set of `JSONSerialization.WritingOptions`.
    func replacing(body value: Any, serializationOptions: JSONSerialization.WritingOptions) -> Self {
        return replacing(body: try? JSONSerialization.data(withJSONObject: value,
                                                           options: serializationOptions))
    }

    /// Replace the current `httpBody` with body-encoded `parameters`.
    /// - parameter parameters: A `Dictionary` of optional `String`s.
    func replacing(body parameters: [String: String?]) -> Self {
        return replacing(body: parameters
            .compactMap { key, value in value.flatMap { "\(key)=\($0)" }}
            .joined(separator: "&")
            .data(using: .utf8)
        )
    }
}
