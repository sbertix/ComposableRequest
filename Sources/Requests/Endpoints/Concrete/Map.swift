//
//  Map.swift
//  Results
//
//  Created by Stefano Bertagno on 07/12/22.
//

import Foundation

#if canImport(Combine)
import Combine
#endif

/// A `struct` defining a custom endpoint
/// implementation handling an output generated
/// from an existing one.
public struct Map<Parent: Endpoint, Output> {
    /// The parent endpoint.
    private let parent: Parent
    /// The content factory.
    private let content: (Parent.Output) throws -> Output

    /// Init.
    ///
    /// - parameters:
    ///     - parent: A valid `Parent` factory.
    ///     - content: A valid content factory.
    public init(
        @EndpointBuilder _ parent: () -> Parent,
        to content: @escaping (Parent.Output) throws -> Output
    ) {
        self.parent = parent()
        self.content = content
    }
}

extension Map: Endpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private)
    public func _resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        var iterator = parent._resolve(with: session).makeAsyncIterator()
        return .init { try await iterator.next().flatMap(content) }
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
        parent._resolve(with: session)
            .tryMap(content)
            .eraseToAnyPublisher()
    }
    #endif
}

extension Map: SingleEndpoint where Parent: SingleEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with session: URLSession) async throws -> Output {
        try await content(parent.resolve(with: session))
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

extension Map: LoopEndpoint where Parent: LoopEndpoint {
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
