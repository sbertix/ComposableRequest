//
//  HandleEvents.swift
//  Requests
//
//  Created by Stefano Bertagno on 17/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining a custom endpoint
/// implementation handling success and failures
/// of an existing one, without modifying them.
public struct HandleEvents<Parent: Endpoint> {
    /// The parent endpoint.
    private let parent: Parent
    /// The event handler.
    private let handler: (Result<Parent.Output, any Error>) -> Void

    /// Init.
    ///
    /// - parameters:
    ///     - parent: A valid `Parent` factory.
    ///     - handler: The event handler.
    public init(
        @EndpointBuilder _ parent: () -> Parent,
        with handler: @escaping (Result<Parent.Output, any Error>) -> Void
    ) {
        self.parent = parent()
        self.handler = handler
    }
}

extension HandleEvents: Endpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private)
    public func _resolve(with session: URLSession) -> AsyncThrowingStream<Parent.Output, any Error> {
        var iterator = parent._resolve(with: session).makeAsyncIterator()
        return .init {
            do {
                guard let result = try await iterator.next() else { return nil }
                handler(.success(result))
                return result
            } catch {
                handler(.failure(error))
                throw error
            }
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
    public func _resolve(with session: URLSession) -> AnyPublisher<Parent.Output, any Error> {
        parent._resolve(with: session)
            .handleEvents(
                receiveOutput: {
                    handler(.success($0))
                },
                receiveCompletion: {
                    guard case .failure(let error) = $0 else { return }
                    handler(.failure(error))
                }
            )
            .eraseToAnyPublisher()
    }
    #endif
}

extension HandleEvents: SingleEndpoint where Parent: SingleEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with session: URLSession) async throws -> Parent.Output {
        do {
            let result = try await parent.resolve(with: session)
            handler(.success(result))
            return result
        } catch {
            handler(.failure(error))
            throw error
        }
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with session: URLSession) -> AnyPublisher<Parent.Output, any Error> {
        _resolve(with: session)
    }
    #endif
}

extension HandleEvents: LoopEndpoint where Parent: LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve(with session: URLSession) -> AsyncThrowingStream<Parent.Output, any Error> {
        _resolve(with: session)
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with session: URLSession) -> AnyPublisher<Parent.Output, any Error> {
        _resolve(with: session)
    }
    #endif
}
