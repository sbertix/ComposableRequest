//
//  Response.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/04/2020.
//

import Foundation

/// A `struct` holding reference to a type-erased `Codable`.
@dynamicMemberLookup
public class Response:
    Codable,
    ExpressibleByBooleanLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByStringLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral
{
    /// The wrapped value.
    public let value: Any

    // MARK: Lifecycle
    /// Init.
    /// - parameter value: The underlying `Value`.
    public init<Value>(_ value: Value) {
        guard let value = value as Any? else { self.value = NSNull(); return }
        if let response = value as? Response { self.value = response.value } else { self.value = value }
    }
    
    /// Init.
    /// - parameter value: A `Bool`.
    public required convenience init(booleanLiteral value: Bool) {
        self.init(value)
    }
    
    /// Init.
    /// - parameter value: An `Int`.
    public required convenience init(integerLiteral value: Int) {
        self.init(value)
    }
    
    /// Init.
    /// - parameter value: A `Double`.
    public required convenience init(floatLiteral value: Double) {
        self.init(value)
    }
    
    /// Init.
    /// - parameter value: A `String`.
    public required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }

    /// Init.
    /// - parameter value: A `String`.
    public required convenience init(stringLiteral value: String) {
        self.init(value)
    }
    
    /// Init.
    /// - parameter value: An `Array` of `Any`s.
    public required convenience init(arrayLiteral elements: Any...) {
        self.init(elements.map(Response.init))
    }
    
    /// Init.
    /// - parameter value: A `Dictionary` of `Any`s.
    public required convenience init(dictionaryLiteral elements: (String, Any)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements).mapValues(Response.init))
    }
    
    /// An empty response.
    /// - returns: A `Response` wrapping `NSNull`.
    public static var empty: Response { return .init(NSNull()) }
    
    // MARK: Codable
    /// Init.
    /// - parameter decoder: A valid `Decoder`.
    public required convenience init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            // Switch types.
            if container.decodeNil() {
                self.init(NSNull())
            } else if let value = try? container.decode(Array<Response>.self) {
                self.init(value)
            } else if let value = try? container.decode(Dictionary<String, Response>.self) {
                self.init(Dictionary(uniqueKeysWithValues: value.map { ($0.camelCased, $1) }))
            } else if let value = try? container.decode(Bool.self) {
                self.init(value)
            } else if let value = try? container.decode(Int.self) {
                self.init(value)
            } else if let value = try? container.decode(Double.self) {
                self.init(value)
            } else if let value = try? container.decode(String.self) {
                self.init(value)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid type for `Response`.")
            }
        }
    }
    
    /// Encode `value`.
    /// - parameter encoder: A valid `Encoder`.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        // Switch types.
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let value as [Any?]:
            try container.encode(value.map(Response.init))
        case let value as [String: Any?]:
            try container.encode(value.mapValues(Response.init))
        case let value as Bool:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as Double:
            try container.encode(value)
        case let value as String:
            try container.encode(value)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid type for `Response`.")
            throw EncodingError.invalidValue(value, context)
        }
    }
    
    /// Encode `value` in `data`.
    /// - throws: An `EncodingError.invalidData`.
    /// - returns: Some valid `Data`.
    public func encode() throws -> Data { return try JSONEncoder().encode(self) }

    /// Decode `data` to `Response`.
    /// - parameter data: Some valid `Data`.
    /// - throws: A `DecodingError.invalidData`.
    /// - returns: A `Response`.
    public static func decode(_ data: Data) throws -> Response {
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

public extension Response {
    /// An optional `Array` of `Response`s.
    func array() -> [Response]? {
        return value as? [Response]
    }

    /// An optional `Bool`.
    func bool() -> Bool? {
        return (value as? NSNumber)?.boolValue
            ?? string().flatMap {
                if ["yes", "y", "true", "t", "1"].contains($0) { return true }
                if ["no", "n", "false", "f", "0"].contains($0) { return false }
                return nil
            }
    }

    /// An optional `Date`.
    func date() -> Date? {
        return (value as? NSNumber).flatMap {
            Date(timeIntervalSince1970: $0.doubleValue/pow(10.0, max(floor(log10($0.doubleValue))-9, 0)))
        }
    }

    /// An optional `Dictionary` of `Response`s.
    func dictionary() -> [String: Response]? {
        return value as? [String: Response]
    }

    /// An optional `Double`.
    func double() -> Double? {
        return (value as? NSNumber)?.doubleValue
            ?? string().flatMap(Double.init)
    }

    /// An optional `Int`.
    func int() -> Int? {
        return (value as? NSNumber)?.intValue
            ?? string().flatMap(Int.init)
    }

    /// An optional `String`.
    func string() -> String? {
        return value as? String
    }

    /// An optional `URL`.
    func url() -> URL? {
        return string().flatMap { URL(string: $0) }
    }

    // MARK: Subscripts
    /// Interrogate `.dictionary`.
    /// - parameter member: A valid `Dictionary` key.
    subscript(dynamicMember member: String) -> Response {
        return dictionary()?[member] ?? .empty
    }

    /// Interrogate `.dictionary`.
    /// - parameter key: A valid `Dictionary` key.
    subscript(key: String) -> Response {
        return dictionary()?[key] ?? .empty
    }

    /// Access the `index`-th item in `.array`.
    /// - parameter index: A valid `Int`.
    subscript(index: Int) -> Response {
        guard let array = array(), index >= 0, index < array.count else { return .empty }
        return array[index]
    }
}

// MARK: CustomStringConvertible
extension Response: CustomDebugStringConvertible, CustomStringConvertible {
    /// The item description.
    public var description: String {
        return (value as Any?).flatMap { String(describing: $0) } ?? "<null>"
    }

    /// The item debug description.
    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "Response("+value.debugDescription+")"
        default:
            return "Response("+description+")"
        }
    }
}

// MARK: Equatable
extension Response: Equatable {
    /// Compare `lhs` with `rhs`.
    /// - parameters:
    ///     - lhs: An `Response`.
    ///     - rhs: An `Response`.
    /// - returns: `true` if `lhs` and `rhs` are equal, `false` otherwise.
    public static func == (lhs: Response, rhs: Response) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (NSNull, NSNull):
            return true
        case let (lhs as [Response], rhs as [Response]):
            return lhs == rhs
        case let (lhs as [String: Response], rhs as [String: Response]):
            return lhs == rhs
        case let (lhs as NSNumber, rhs as NSNumber):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        default:
            return false
        }
    }
}
