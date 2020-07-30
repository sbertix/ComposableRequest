//
//  ResponseMappable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 30/07/20.
//

import Foundation

/// A `protocol` defining a type initiable through `Response`.
@dynamicMemberLookup
public protocol ResponseMappable: Codable {
    /// The actual `Response`.
    var response: () throws -> Response { get set }

    /// Init.
    /// - parameter response: A valid `Response`.
    init(response: @autoclosure @escaping () throws -> Response) rethrows
}

public extension ResponseMappable {
    /// Interrogate `response.dictionary`.
    /// - parameter member: A valid `Dictionary` key.
    subscript(dynamicMember member: String) -> Response {
        return (try? response())?.dictionary()?[member] ?? .empty
    }

    /// Interrogate `response.dictionary`.
    /// - parameter key: A valid `Dictionary` key.
    subscript(key: String) -> Response {
        return (try? response())?.dictionary()?[key] ?? .empty
    }

    /// Access the `index`-th item in `response.array`.
    /// - parameter index: A valid `Int`.
    subscript(index: Int) -> Response {
        guard let array = (try? response())?.array(), index >= 0, index < array.count else { return .empty }
        return array[index]
    }
}

public extension ResponseMappable {
    /// Encode the `Response`.
    /// - parameter encode: A valid `Encoder`.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(response())
    }

    /// Decode the `Response`.
    /// - parameter decode: A valid `Decoder`
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(response: try container.decode(Response.self))
    }
}
