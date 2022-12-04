//
//  AnyDecodable.swift
//  Requests
//
//  Created by Stefano Bertagno on 16/11/22.
//

import Foundation

/// A `struct` defining an instance
/// capable of parsing some generic
/// JSON file.
@dynamicMemberLookup public struct AnyDecodable {
    /// Whether it should convert from snake case or not. Defaults to `false`.
    private let convertFromSnakeCase: Bool
    /// Some decoded value.
    private let decodedValue: Any

    /// Simplify into an optional `Bool`.
    public var bool: Bool? {
        switch decodedValue {
        case let value as NSNumber:
            return value.boolValue
        case let string as String:
            switch string.lowercased() {
            case "y", "yes", "t", "true", "1": return true
            case "n", "no", "f", "false", "0": return false
            default: return nil
            }
        default:
            return nil
        }
    }
    
    /// Simplify into an optional `Double`.
    public var double: Double? {
        switch decodedValue {
        case let value as NSNumber: return value.doubleValue
        case let string as String: return Double(string)
        default: return nil
        }
    }

    /// Simplify into an optional `Int`.
    public var int: Int? {
        switch decodedValue {
        case let value as NSNumber: return value.intValue
        case let string as String: return Int(string)
        default: return nil
        }
    }

    /// Simplify into an optional `String`.
    public var string: String? {
        switch decodedValue {
        case let string as String: return string
        case let value as NSNumber: return value.stringValue
        default: return nil
        }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - decodedValue: Some decoded value.
    ///     - convertFromSnakeCase: Some `Bool`.
    private init<T>(_ decodedValue: T, convertFromSnakeCase: Bool = false) {
        self.decodedValue = decodedValue
        self.convertFromSnakeCase = convertFromSnakeCase
    }
    
    /// Change all keys to be decoded using camel case.
    ///
    /// "someKey" -> "some_key".
    ///
    /// - returns: Some `AnyEncodable`.
    public func fromSnakeCase() -> AnyDecodable {
        .init(decodedValue, convertFromSnakeCase: true)
    }
    
    /// Look up a specific key inside
    /// `decodedValue`, if it is a dictionary.
    ///
    /// - parameter key: Some `String`.
    /// - returns: Some optional `AnyDecodable`.
    public subscript(dynamicMember key: String) -> AnyDecodable {
        self[convertFromSnakeCase ? key.snakeCased : key]
    }

    /// Look up a specific key inside
    /// `decodedValue`, if it is a dictionary.
    ///
    /// - parameter key: Some `String`.
    /// - returns: Some `AnyDecodable`.
    public subscript(_ key: String) -> AnyDecodable {
        guard let dictionary = decodedValue as? [String: Any],
              let value = dictionary[convertFromSnakeCase ? key.snakeCased : key] else {
            return AnyDecodable(NSNull(), convertFromSnakeCase: convertFromSnakeCase)
        }
        return (value as? AnyDecodable) ?? AnyDecodable(value, convertFromSnakeCase: convertFromSnakeCase)
    }

    /// Look up a specific offset inside
    /// `decodedValue`, if it is an array.
    ///
    /// - note: Out-of-bound offsets **DO NOT** raise an exception.
    /// - parameter offset: Some `Int`.
    /// - returns: Some `AnyDecodable`.
    public subscript(_ offset: Int) -> AnyDecodable {
        guard let array = decodedValue as? [Any],
              array.count > offset else {
            return AnyDecodable(NSNull())
        }
        let value = array[offset]
        return (value as? AnyDecodable) ?? AnyDecodable(value)
    }
}

extension AnyDecodable: Decodable {
    /// Init.
    ///
    /// - parameter decoder: Some `Decoder`.
    /// - throws: A `DecodingError`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.init(NSNull())
        } else if let value = try? container.decode(Bool.self) {
            self.init(value)
        } else if let value = try? container.decode(Double.self) {
            self.init(value)
        } else if let value = try? container.decode(Int.self) {
            self.init(value)
        } else if let value = try? container.decode(String.self) {
            self.init(value)
        } else if let value = try? container.decode([AnyDecodable].self) {
            self.init(value.map(\.decodedValue))
        } else if let value = try? container.decode([String: AnyDecodable].self) {
            self.init(value.mapValues(\.decodedValue))
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Type not supported by `AnyDecodable`."
            )
        }
    }
}

extension AnyDecodable: CustomStringConvertible {
    /// A human-readable description.
    public var description: String {
        switch decodedValue {
        case let value as CustomStringConvertible:
            return value.description
        case let value:
            return String(describing: value)
        }
    }
}

extension AnyDecodable: CustomDebugStringConvertible {
    /// A human-readable debug description.
    public var debugDescription: String {
        switch decodedValue {
        case let value as CustomDebugStringConvertible:
            return "AnyDecodable(\(value.debugDescription))"
        default:
            return "AnyDecodable(\(description))"
        }
    }
}
