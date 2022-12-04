//
//  LoopEndpoint.swift
//  Requests
//
//  Created by Stefano Bertagno on 15/11/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `protocol` defining an instance targeting
/// a single endpoint, capable of pagination.
public protocol LoopEndpoint<Output>: Endpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    func resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error>

    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `Publisher`.
    func resolve(with session: URLSession) -> AnyPublisher<Output, any Error>
    #endif
}

public extension LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private)
    func _resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        resolve(with: session)
    }

    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `Publisher`.
    func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        _resolve(with: session)
    }
    #endif
}

public extension LoopEndpoint {
    /// Erase to `AnyLoopEndpoint`.
    ///
    /// - returns: A valid `AnyLoopEndpoint`.
    func eraseToAnyLoopEndpoint() -> AnyLoopEndpoint<Output> {
        .init(self)
    }
}
