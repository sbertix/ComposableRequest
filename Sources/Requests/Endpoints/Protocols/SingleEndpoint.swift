//
//  SingleEndpoint.swift
//  Requests
//
//  Created by Stefano Bertagno on 14/11/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `protocol` defining an instance targeting
/// a single endpoint, incapable of pagination.
public protocol SingleEndpoint<Output>: Endpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    func resolve(with session: URLSession) async throws -> Output

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    func resolve(with session: URLSession) -> AnyPublisher<Output, any Error>
    #endif
}

public extension SingleEndpoint {
    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        // Hold reference to the task, so we can cancel
        // it according to the `Publisher` stream.
        var task: Task<Void, Never>?
        return Deferred {
            Future { subscriber in
                task = .init {
                    guard !Task.isCancelled else { return }
                    await subscriber(Result.async { try await resolve(with: session) })
                }
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
    #endif

    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private)
    func _resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        // You should only ever return one
        // item.
        // We could use `prefix`, but we
        // still want to return `AsyncThrowingStream`
        // as we can't use generic types in
        // protocols at runtime without increasing
        // minimum versions.
        let nextInput: NextInput<Void> = .init(())
        return .init {
            // If next input is `nil`, cancel the stream.
            guard await nextInput.value != nil else { return nil }
            await nextInput.update(with: nil)
            return try await resolve(with: session)
        }
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    @_spi(Private)
    func _resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        resolve(with: session)
    }
    #endif
}

public extension SingleEndpoint {
    /// Erase to `AnySingleEndpoint`.
    ///
    /// - returns: A valid `AnySingleEndpoint`.
    func eraseToAnySingleEndpoint() -> AnySingleEndpoint<Output> {
        .init(self)
    }

    /// Erase to `AnyLoopEndpoint`.
    ///
    /// - returns: A valid `AnyLoopEndpoint`.
    func eraseToAnyLoopEndpoint() -> AnyLoopEndpoint<Output> {
        .init(ForEach([()]) { _ in self })
    }

    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    ///
    /// - parameter child: Some `Endpoint` factory.
    /// - returns: Some `FlatMap`.
    func flatMap<E: Endpoint>(@EndpointBuilder to child: @escaping (Output) -> E) -> FlatMap<Self, E> {
        .init { self } to: { child($0) }
    }
}
