//
//  Wrapped.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 30/07/20.
//

import Foundation

/// A `protocol` defining a type initiable through `Response`.
@dynamicMemberLookup
public protocol Wrapped: Codable, Wrappable {
    /// A closure escaping the actual underlying `Wrapper`.
    var wrapper: () -> Wrapper { get }

    /// Init.
    ///
    /// - parameter wrapper: A closure returning a `Wrapper`.
    init(wrapper: @escaping () -> Wrapper)
}

extension Wrapper: Wrapped {
    /// A closure escaping `self`.
    public var wrapper: () -> Wrapper { { self } }

    /// Init.
    ///
    /// - parameter wrapper: A closure returning `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self = wrapper()
    }
}

public extension Wrapped {
    // MARK: Wrappable

    /// Return the underlying `Wrapper`.
    var wrapped: Wrapper { wrapper() }

    // MARK: Lifecycle

    /// Init.
    ///
    /// - parameter response: A valid `Wrapper`.
    init(wrapper: Wrapper) {
        self.init { wrapper }
    }

    /// Decode the `Wrapper`.
    ///
    /// - parameter decode: A valid `Decoder`
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(wrapper: try container.decode(Wrapper.self))
    }

    // MARK: Codable

    /// Encode the `Wrapper`.
    ///
    /// - parameter encode: A valid `Encoder`.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrapper())
    }

    // MARK: Subscript

    /// Interrogate `wrapper.dictionary`.
    ///
    /// - parameter member: A valid `Dictionary` key.
    subscript(dynamicMember member: String) -> Wrapper {
        return wrapper()[member]
    }

    /// Interrogate `wrapper.dictionary`.
    ///
    /// - parameter key: A valid `Dictionary` key.
    subscript(key: String) -> Wrapper {
        return wrapper()[key]
    }

    /// Access the `index`-th item in `wrapper.array`.
    ///
    /// - parameter index: A valid `Int`.
    subscript(index: Int) -> Wrapper {
        return wrapper()[index]
    }
}
