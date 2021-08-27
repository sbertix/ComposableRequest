//
//  Wrapper.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 09/08/20.
//

import Foundation

/// A `struct` defining a generic and abstract `Codable` value.
@dynamicMemberLookup
public struct Wrapper {
    /// An accessory for an empty `Wrapper`.
    public static var empty: Wrapper { .init(value: NSNull()) }

    /// The underlying value.
    public var value: Wrappable

    /// Evalutes to `true` if `value` is an instance of `NSNull`, `false` otherwise.
    public var isEmpty: Bool {
        // Check for `NSNull`.
        if value is NSNull || description == "<null>" { return true }
        // Check all accessories for `nil`.
        return !([array(),
                  bool(converting: false),
                  date(converting: false),
                  dictionary(),
                  double(converting: false),
                  int(converting: false),
                  string(converting: false),
                  url()] as [Any?])
            .lazy
            .contains { $0 != nil }
    }

    /// Init.
    ///
    /// - parameter value: A `JSONSerialization` compatible value.
    /// - note: Use `value.wrapped` instead of initializing `Wrapper` directly.
    init(value: Wrappable) { self.value = value }

    /// Decode `data` into a `Wrapper`.
    ///
    /// - parameter data: Some valid `Data`.
    /// - note: Prefer this, to using a custom `JSONDecoder`.
    /// - throws: An `DecodingError`.
    /// - returns: A valid `Wrapper`.
    public static func decode(_ data: Data) throws -> Wrapper { try JSONDecoder().decode(Wrapper.self, from: data) }

    /// Encode `self` into `Data`.
    ///
    /// - note: Prefer this, to using a custom `JSONEncoder`.
    /// - throws: An `EncodingError`.
    /// - returns: Some valid `Data`.
    public func encode() throws -> Data { try JSONEncoder().encode(self) }

    /// Flat map to `self`.
    ///
    /// - returns: `self` if `isEmpty` is `false`, `nil` otherwise.
    public func optional() -> Wrapper? { isEmpty ? .none : self }

    /// Turn a custom `Wrapper` keys to _snake_case_.
    ///
    /// - returns: A valid `Wrapper`.
    public func snakeCased() -> Wrapper {
        switch value {
        case let array as [Wrapper]:
            return array.map { $0.snakeCased() }.wrapped
        case let dictionary as [String: Wrapper]:
            return Dictionary(dictionary.map { ($0.snakeCased, $1.snakeCased()) }) { lhs, _ in lhs }.wrapped
        default:
            return self
        }
    }

    /// Turn a custom `Wrapper` keys to _camelCase_.
    ///
    /// - returns: A valid `Wrapper`.
    public func camelCased() -> Wrapper {
        switch value {
        case let array as [Wrapper]:
            return array.map { $0.camelCased() }.wrapped
        case let dictionary as [String: Wrapper]:
            return Dictionary(dictionary.map { ($0.camelCased, $1.camelCased()) }) { lhs, _ in lhs }.wrapped
        default:
            return self
        }
    }

    // MARK: Subscripts

    /// Interrogate `dictionary`.
    ///
    /// - parameter member: A valid `Dictionary` key.
    /// - returns: The `Wrapper` at `member` key, or `.empty` if it does not exist.
    public subscript(dynamicMember member: String) -> Wrapper {
        get { optional()?.dictionary()?[member] ?? .empty }
        set(newValue) {
            guard var dictionary = dictionary() else { return }
            dictionary[member] = newValue
            value = dictionary
        }
    }

    /// Interrogate `dictionary`.
    ///
    /// - parameter key: A valid `Dictionary` key.
    /// - returns: The `Wrapper` at `member` key, or `.empty` if it does not exist.
    public subscript(key: String) -> Wrapper {
        get { optional()?.dictionary()?[key] ?? .empty }
        set(newValue) {
            guard var dictionary = dictionary() else { return }
            dictionary[key] = newValue
            value = dictionary
        }
    }

    /// Interrogate `array`.
    ///
    /// - parameter index: A valid `Int`.
    /// - returns: The `Wrapper` at `index`, or `.empty` if it does not exist.
    public subscript(index: Int) -> Wrapper {
        guard let array = optional()?.array(), index >= 0, index < array.count else { return .empty }
        return array[index]
    }
}

public extension Wrapper {
    /// An optional array of `Wrapper`s
    ///
    /// - returns: An array of `Wrapper`s, if `value` is an array, `nil` otherwise.
    func array() -> [Wrapper]? { value as? [Wrapper] }

    /// An optional `Bool`.
    ///
    /// - parameter shouldConvert: A `Bool` referencing whether you should try to read `Bool` from `String`s or not. Defaults to `true`.
    /// - returns: A `Bool`, if `value`is a `NSNumber` or it can be converted to a `Bool` and `shouldConvert` is `true` , `nil` otherwise.
    func bool(converting shouldConvert: Bool = true) -> Bool? {
        switch value {
        case let number as NSNumber:
            return number.boolValue
        case let string as String where shouldConvert:
            switch string.lowercased() {
            case "y", "yes", "t", "true", "1":
                return true
            case "n", "no", "f", "false", "0":
                return false
            default:
                return nil
            }
        default:
            return nil
        }
    }

    /// An optional `Date`, as seconds since `reference`.
    ///
    /// - parameters:
    ///     - reference: A `Date` representing when to start counting seconds. Defauts to midnight, Jenuary 1st, 1970.
    ///     - shouldConver: A `Bool` referencing whether you should try to read `Date` from `String`s or not. Defaults to `false`.
    /// - returns: A `Date`, if `value` is a `Date`, `nil` otherwise.
    func date(countingFrom reference: Date = .init(timeIntervalSince1970: 0),
              converting shouldConvert: Bool = false) -> Date? {
        switch value {
        case let number as NSNumber:
            let double = number.doubleValue
            let seconds = double / pow(10.0, max(floor(log10(double)) - 9, 0))
            return reference.addingTimeInterval(seconds)
        case let string as String where shouldConvert:
            let double = Double(string)
            let seconds = double.flatMap { $0 / pow(10.0, max(floor(log10($0)) - 9, 0)) }
            return seconds.flatMap { reference.addingTimeInterval($0) }
        default:
            return nil
        }
    }

    /// An optional dictionary of `Wrapper`s
    ///
    /// - returns: A dictionary of `Wrapper`s, if `value` is a dictionary, `nil` otherwise.
    func dictionary() -> [String: Wrapper]? { value as? [String: Wrapper] }

    /// An optional `Double`.
    ///
    /// - parameter shouldConvert: A `Bool` referencing whether you should try to read `Double` from `String`s or not. Defaults to `true`.
    /// - returns: A `Double`, if `value`is a `NSNumber` or it can be converted to a `Double` and `shouldConvert` is `true` , `nil` otherwise.
    func double(converting shouldConvert: Bool = true) -> Double? {
        switch value {
        case let number as NSNumber:
            return number.doubleValue
        case let string as String where shouldConvert:
            return Double(string)
        default:
            return nil
        }
    }

    /// An optional `Int`.
    ///
    /// - parameter shouldConvert: A `Bool` referencing whether you should try to read `Int` from `String`s or not. Defaults to `true`.
    /// - returns: An `Int`, if `value`is a `NSNumber` or it can be converted to a `Int` and `shouldConvert` is `true` , `nil` otherwise.
    func int(converting shouldConvert: Bool = true) -> Int? {
        switch value {
        case let number as NSNumber:
            return number.intValue
        case let string as String where shouldConvert:
            return Int(string)
        default:
            return nil
        }
    }

    /// An optional `String`.
    ///
    /// - parameter shouldConvert: A `Bool` referencing whether you should try to read `String` from `NSNumber`s or not. Defaults to `false`.
    /// - returns: A `String`, if `value`is a `String` or it can be converted to a `String` and `shouldConvert` is `true` , `nil` otherwise.
    func string(converting shouldConvert: Bool = false) -> String? {
        switch value {
        case let number as NSNumber where shouldConvert:
            return number.description
        case let string as String:
            return string
        default:
            return nil
        }
    }

    /// An optional `URL`.
    ///
    /// - returns: A `URL`, if `value` is a `String` representing a valid (local or remote) URL address, `nil` otherwise.
    func url() -> URL? {
        switch value {
        case let string as String:
            return URL(string: string) ?? URL(fileURLWithPath: string)
        default:
            return nil
        }
    }
}

extension Wrapper: Codable {
    /// Init.
    ///
    /// - parameter decoder: A valid `Decoder`.
    /// - throws: A `DecodingError`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.init(value: NSNull())
        } else if let array = try? container.decode([Wrapper].self) {
            self.init(value: array)
        } else if let dictionary = try? container.decode([String: Wrapper].self) {
            self.init(value: Dictionary(dictionary.map { ($0.camelCased, $1) }, uniquingKeysWith: { _, rhs in rhs }))
        } else if let value = try? container.decode(Bool.self) {
            self.init(value: value)
        } else if let value = try? container.decode(Int.self) {
            self.init(value: value)
        } else if let value = try? container.decode(Double.self) {
            self.init(value: value)
        } else if let string = try? container.decode(String.self) {
            self.init(value: string)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid type for `Wrapper`.")
        }
    }

    /// Encode `value`.
    ///
    /// - parameter encoder: A valid `Encoder`.
    /// - throws: An `EncodingError`.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let array as [Wrapper]:
            try container.encode(array)
        case let dictionary as [String: Wrapper]:
            try container.encode(Dictionary(uniqueKeysWithValues: dictionary.map { ($0.snakeCased, $1) }))
        case let value as Bool:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as Double:
            try container.encode(value)
        case let string as String:
            try container.encode(string)
        default:
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: container.codingPath,
                                                                   debugDescription: "Invalid type for `Wrapper`."))
        }
    }
}

extension Wrapper: CustomStringConvertible {
    /// `Wrapper` `description` always describes `value` and nothing more.
    public var description: String { .init(describing: value) }

    /// `self` `JSON` representation.
    ///
    /// - throws: An `EncodingError`.
    /// - returns: An optional `String`.
    public func jsonRepresentation() throws -> String? { try String(data: encode(), encoding: .utf8) }
}

extension Wrapper: Equatable {
    /// Whether `lhs` and `rhs` were equal.
    ///
    /// - parameters:
    ///     - lhs: A `Wrapper`.
    ///     - rhs: A `Wrapper`.
    /// - returns: `true` if `lhs` and `rhs` are equal, otherwise `false`.
    public static func == (lhs: Wrapper, rhs: Wrapper) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (NSNull, NSNull):
            return true
        case let (lhs, rhs) as ([Wrapper], [Wrapper]):
            return lhs == rhs
        case let (lhs, rhs) as ([String: Wrapper], [String: Wrapper]):
            return lhs == rhs
        case let (lhs, rhs) as (NSNumber, NSNumber):
            return lhs == rhs
        case let (lhs, rhs) as (String, String):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension Wrapper: ExpressibleByArrayLiteral {
    /// Init with an array representation.
    ///
    /// - parameter elements: An collection of `Wrapper`s.
    public init(arrayLiteral elements: Wrapper...) { self.init(arrayLiteral: elements) }

    /// Init with an array.
    ///
    /// - parameter elements: An array of `Wrapper`s.
    public init(arrayLiteral elements: [Wrapper]) { self.init(value: elements.filter { !$0.isEmpty }) }
}

extension Wrapper: ExpressibleByBooleanLiteral {
    /// Init with a boolean representation.
    ///
    /// - parameter value: A valid `Bool`.
    public init(booleanLiteral value: BooleanLiteralType) { self.init(value: value) }
}

extension Wrapper: ExpressibleByDictionaryLiteral {
    /// Init with a dictionary representation.
    ///
    /// - parameter elements: A collection of `String`s and `Wrapper`s.
    public init(dictionaryLiteral elements: (String, Wrapper)...) {
        self.init(dictionaryLiteral: Dictionary(elements.compactMap { $1.isEmpty ? nil : ($0.camelCased, $1) }) { $1 })
    }

    /// Init with a dictionary representation.
    ///
    /// - parameter elements: A dictionary of `Wrapper`s.
    public init(dictionaryLiteral elements: [String: Wrapper]) { self.init(value: elements) }
}

extension Wrapper: ExpressibleByFloatLiteral {
    /// Init with a double representation.
    ///
    /// - parameter value: A valid `Float`.
    public init(floatLiteral value: FloatLiteralType) { self.init(value: value) }
}

extension Wrapper: ExpressibleByIntegerLiteral {
    /// Init with an integer representation.
    ///
    /// - parameter value: A valid `Integer`.
    public init(integerLiteral value: IntegerLiteralType) { self.init(value: value) }
}

extension Wrapper: ExpressibleByStringLiteral {
    /// Init with a string representation.
    ///
    /// - parameter value: A valid `String`.
    public init(stringLiteral value: StringLiteralType) { self.init(value: value) }
}
