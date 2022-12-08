//
//  Catch.swift
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
/// by an error in the previous one.
///
/// This is only available for `SingleEndpoint`
/// `Child`s cause we want to be sure to
/// guarantee a deterministic ordering for outputs
/// which is choerent with user expectations (i.e.
/// work like **Combine**), and it wouldn't
/// otherwise be possible by extending it to
/// `LoopEndpoint`s.
public struct Catch<Parent: Endpoint, Child: SingleEndpoint> where Child.Output == Parent.Output {
    /// The associated output type.
    public typealias Output = Child.Output

    /// The parent endpoint.
    private let parent: Parent
    /// The child factory.
    private let child: (any Error) -> Child

    /// Init.
    ///
    /// - parameters:
    ///     - parent: A valid `Parent` factory.
    ///     - child: A valid `Child` factory.
    public init(
        @EndpointBuilder _ parent: () -> Parent,
        @EndpointBuilder to child: @escaping (any Error) -> Child
    ) {
        self.parent = parent()
        self.child = child
    }
}

extension Catch: Endpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private)
    public func _resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        var iterator: AsyncThrowingStream<Output, any Error>.AsyncIterator? = parent
            ._resolve(with: session)
            .makeAsyncIterator()
        return .init {
            do {
                return try await iterator?.next()
            } catch {
                iterator = nil
                return try await child(error).resolve(with: session)
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
    public func _resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        parent._resolve(with: session)
            .catch { child($0).resolve(with: session).prefix(1) }
            .eraseToAnyPublisher()
    }
    #endif
}

extension Catch: SingleEndpoint where Parent: SingleEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with session: URLSession) async throws -> Output {
        do {
            return try await parent.resolve(with: session)
        } catch {
            return try await child(error).resolve(with: session)
        }
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        parent.resolve(with: session)
            .catch { child($0).resolve(with: session).prefix(1) }
            .eraseToAnyPublisher()
    }
    #endif
}

extension Catch: LoopEndpoint where Parent: LoopEndpoint {
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
