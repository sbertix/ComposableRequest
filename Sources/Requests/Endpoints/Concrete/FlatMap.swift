//
//  FlatMap.swift
//  Requests
//
//  Created by Stefano Bertagno on 04/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining a custom endpoint
/// implementation handling a request generated
/// by the response of a previous one.
///
/// This is only available for `SingleEndpoint`
/// `Parent`s cause we want to be sure to
/// guarantee a deterministic ordering for outputs
/// which is choerent with user expectations (i.e.
/// work like **Combine**), and it wouldn't
/// otherwise be possible by extending it to
/// `LoopEndpoint`s.
public struct FlatMap<Parent: SingleEndpoint, Child: Endpoint> {
    /// The associated output type.
    public typealias Output = Child.Output

    /// The parent endpoint.
    private let parent: Parent
    /// The child factory.
    private let child: (Parent.Output) -> Child

    /// Init.
    ///
    /// - parameters:
    ///     - parent: A valid `Parent` factory.
    ///     - child: A valid `Child` factory.
    public init(
        @EndpointBuilder _ parent: () -> Parent,
        @EndpointBuilder to child: @escaping (Parent.Output) -> Child
    ) {
        self.parent = parent()
        self.child = child
    }
}

extension FlatMap: Endpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private)
    public func _resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        var iterator: AsyncThrowingStream<Child.Output, any Error>.AsyncIterator?
        return .init {
            if iterator == nil {
                let output = try await parent.resolve(with: session)
                iterator = child(output)._resolve(with: session).makeAsyncIterator()
            }
            return try await iterator?.next()
        }
    }

    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private)
    public func _resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        parent.resolve(with: session)
            .flatMap { child($0)._resolve(with: session) }
            .eraseToAnyPublisher()
    }
    #endif
}

extension FlatMap: SingleEndpoint where Child: SingleEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with session: URLSession) async throws -> Output {
        try await child(try await parent.resolve(with: session)).resolve(with: session)
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        parent.resolve(with: session)
            .flatMap { child($0).resolve(with: session) }
            .eraseToAnyPublisher()
    }
    #endif
}

extension FlatMap: LoopEndpoint where Child: LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        _resolve(with: session)
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        _resolve(with: session)
    }
    #endif
}
