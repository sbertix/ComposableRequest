//
//  BodyComposable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// An `enum` defining `BodyParsable` related `Error`s.
public enum BodyError: Error {
    /// Invalid data.
    case invalidData
    /// No valid parameters.
    case noValidParameters
}

/// A `protocol` representing a composable `URLRequest` body.
public protocol BodyComposable {
    /// Replace the current `httpBody` with `data`.
    /// - parameter data: An optional `Data`.
    func replacing(body data: Data?) -> Self
}

/// A `protocol` representing a `URLRequest` gettable body.
public protocol BodyParsable {
    /// An `httpBody`.
    var body: Data? { get }
}

public extension BodyComposable {
    /// Replace the current `httpBody` with a JSON-encoded `value`.
    /// - parameters
    ///     - value: `Any` value.
    ///     - serializationOptions: A set of `JSONSerialization.WritingOptions`.
    /// - returns: An updated `self`.
    func replacing(body value: Any, serializationOptions: JSONSerialization.WritingOptions) -> Self {
        return replacing(body: try? JSONSerialization.data(withJSONObject: value,
                                                           options: serializationOptions))
    }

    /// Replace the current `httpBody` with body-encoded `parameters`.
    /// - parameters:
    ///     - parameters: A `Dictionary` of optional `String`s.
    ///     - characterSet: An optional `CarachterSet` used for escaping values. Defaults to `.urlQueryValueAllowed`.
    /// - returns: An updated `self`.
    func replacing(body parameters: [String: String?], escaping characterSet: CharacterSet? = .urlQueryValueAllowed) -> Self {
        return replacing(body: parameters
            .compactMap { key, value in
                value.flatMap { value in characterSet.flatMap { value.addingPercentEncoding(withAllowedCharacters: $0) } ?? value }
                    .flatMap { "\(key)=\($0)" }
            }
            .joined(separator: "&")
            .data(using: .utf8)
        )
    }
}

public extension BodyComposable where Self: BodyParsable {
    /// Update the current `httpBody` if set through `parameters`.
    /// - parameters:
    ///     - parameters: A `Dictionary` of optional `String`s.
    ///     - characterSet: An optional `CarachterSet` used for escaping values. Defaults to `.urlQueryValueAllowed`.
    /// - throws: A `BodyError`, when `body` cannot be parsed as URL query parameters.
    /// - returns: An updated `self`.
    func appending(body parameters: [String: String?], escaping characterSet: CharacterSet? = .urlQueryValueAllowed) throws -> Self {
        switch body {
        case .none: return replacing(body: parameters)
        case let body?:
            // Parse the current `httpBody`.
            guard let encoded = String(data: body, encoding: .utf8) else { throw BodyError.invalidData }
            guard encoded.isEmpty || encoded.contains("=") else { throw BodyError.noValidParameters }
            let components = Dictionary(uniqueKeysWithValues: encoded
                .components(separatedBy: "&")
                .map { $0.components(separatedBy: "=") }
                .compactMap { $0.count == 2 ? ($0[0], $0[1].removingPercentEncoding ?? $0[1]) : nil })
            // Update parameters.
            return replacing(body: parameters.merging(components) { lhs, _ in lhs }, escaping: characterSet)
        }
    }

    /// Update the current `httpBody` if set through `parameters`.
    /// - parameters:
    ///     - key: A `String`.
    ///     - value: An optional `String`.
    ///     - characterSet: An optional `CarachterSet` used for escaping values. Defaults to `.urlQueryValueAllowed`.
    /// - throws: A `BodyError`, when `body` cannot be parsed as URL query parameters.
    /// - returns: An updated `self`.
    func appending(body key: String, value: String?, escaping characterSet: CharacterSet? = .urlQueryValueAllowed) throws -> Self {
        return try appending(body: [key: value], escaping: characterSet)
    }
}
