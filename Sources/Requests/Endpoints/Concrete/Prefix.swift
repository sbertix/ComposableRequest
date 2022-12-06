//
//  Prefix.swift
//  Requests
//
//  Created by Stefano Bertagno on 07/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining a custom endpoint
/// implementation returning a wrapper for the
/// first `count` output of a loop endpoint.
public struct Prefix<Parent: LoopEndpoint> {
    /// The associated output type.
    public typealias Output = Parent.Output

    /// The number of items to emit.
    private let count: Int
    /// The parent endpoint.
    private let parent: Parent

    /// Init.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - parent: A valid `Parent` factory.
    public init(_ count: Int, @EndpointBuilder _ parent: () -> Parent) {
        self.count = count
        self.parent = parent()
    }
}

extension Prefix: LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        var iterator = parent.resolve(with: session).prefix(count).makeAsyncIterator()
        return .init { try await iterator.next() }
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        parent.resolve(with: session)
            .prefix(count)
            .eraseToAnyPublisher()
    }
    #endif
}
