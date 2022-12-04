//
//  AnyCodable.swift
//  Requests
//
//  Created by Stefano Bertagno on 16/11/22.
//

import Foundation

/// A `struct` defining an instance
/// capable of being parsed into some
/// generic JSON file.
public struct AnyEncodable {
    /// Some encodable value.
    private let encodableValue: Any
    
    /// Whether it should convert to snake case or not. Defaults to `false`.
    private let convertToSnakeCase: Bool
        
    /// A recursive encodable value.
    private var recursiveEncodableValue: Any {
        (encodableValue as? AnyEncodable)?.recursiveEncodableValue ?? encodableValue
    }
    
    /// Init.
    ///
    /// - parameters:
    ///     - encodableValue: Some encodable value.
    ///     - convertToSnakeCase: Some `Bool`.
    private init<T>(_ encodableValue: T, convertToSnakeCase: Bool) {
        self.encodableValue = (encodableValue as? AnyEncodable)?.recursiveEncodableValue ?? encodableValue
        self.convertToSnakeCase = convertToSnakeCase
    }
    
    /// Init.
    ///
    /// - parameter encodableValue: Some encodable value.
    public init<T>(_ encodableValue: T) {
        self.init(encodableValue, convertToSnakeCase: false)
    }
    
    /// Change all keys to be encoded using snake case.
    ///
    /// "someKey" -> "some_key".
    ///
    /// - returns: Some `AnyEncodable`.
    public func toSnakeCase() -> AnyEncodable {
        .init(self, convertToSnakeCase: true)
    }
}

extension AnyEncodable: Encodable {
    /// Encode using some `Encoder`.
    ///
    /// - throws: An `EncodingError`.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch encodableValue {
        case is NSNull:
            try container.encodeNil()
        case is Void:
            try container.encodeNil()
        case let value as Bool:
            try container.encode(value)
        case let value as Double:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as String:
            try container.encode(value)
        case let value as [Any]:
            try container.encode(value.map { AnyEncodable($0, convertToSnakeCase: convertToSnakeCase) })
        case let value as [String: Any] where convertToSnakeCase:
            try container.encode(Dictionary(uniqueKeysWithValues: value.map {
                ($0.key.snakeCased, AnyEncodable($0.value, convertToSnakeCase: convertToSnakeCase))
            }))
        case let value as [String: Any]:
            try container.encode(value.mapValues { AnyEncodable($0, convertToSnakeCase: convertToSnakeCase) })
        case let value:
            throw EncodingError.invalidValue(
                value,
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Type not supported by `AnyEncodable`."
                )
            )
        }
    }
}

extension AnyEncodable: CustomStringConvertible {
    /// A human-readable description.
    public var description: String {
        switch encodableValue {
        case let value as CustomStringConvertible:
            return value.description
        case let value:
            return String(describing: value)
        }
    }
}

extension AnyEncodable: CustomDebugStringConvertible {
    /// A human-readable debug description.
    public var debugDescription: String {
        switch encodableValue {
        case let value as CustomDebugStringConvertible:
            return "AnyEncodable(\(value.debugDescription))"
        default:
            return "AnyEncodable(\(description))"
        }
    }
}
