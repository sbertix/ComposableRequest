//
//  Wrapped.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 30/07/20.
//

import Foundation

/// A `protocol` defining a type initiable through `Response`.
@dynamicMemberLookup
public protocol Wrapped: Codable {
    /// The actual `Wrapper`.
    var wrapper: () -> Wrapper { get set }

    /// Init.
    /// - parameter wrapper: A closure returning a `Wrapper`.
    init(wrapper: @escaping () -> Wrapper)
}

public extension Wrapped {
    /// Init.
    /// - parameter wrapper: A closure returning a `Wrapper`.
    init(wrapper: @escaping () throws -> Wrapper) rethrows {
        self.init(wrapper: { (try? wrapper()) ?? .empty })
    }

    /// Init.
    /// - parameter response: A valid `Wrapper`.
    init(wrapper: Wrapper) {
        self.init(wrapper: { wrapper })
    }

    /// Interrogate `wrapper.dictionary`.
    /// - parameter member: A valid `Dictionary` key.
    subscript(dynamicMember member: String) -> Wrapper {
        return wrapper()[member]
    }

    /// Interrogate `wrapper.dictionary`.
    /// - parameter key: A valid `Dictionary` key.
    subscript(key: String) -> Wrapper {
        return wrapper()[key]
    }

    /// Access the `index`-th item in `wrapper.array`.
    /// - parameter index: A valid `Int`.
    subscript(index: Int) -> Wrapper {
        return wrapper()[index]
    }
}

public extension Wrapped {
    /// Encode the `Wrapper`.
    /// - parameter encode: A valid `Encoder`.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrapper())
    }

    /// Decode the `Wrapper`.
    /// - parameter decode: A valid `Decoder`
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(wrapper: try container.decode(Wrapper.self))
    }
}
