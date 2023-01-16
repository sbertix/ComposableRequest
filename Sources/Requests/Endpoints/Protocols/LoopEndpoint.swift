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
    /// - parameter session: The `EndpointResolver` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    func resolve<R: EndpointResolver>(with session: R) -> AsyncThrowingStream<Output, any Error>

    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `EndpointResolver` used to fetch the response.
    /// - returns: Some `Publisher`.
    func resolve<R: EndpointResolver>(with session: R) -> AnyPublisher<Output, any Error>
    #endif
}

public extension LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `EndpointResolver` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private)
    func _resolve<R: EndpointResolver>(with session: R) -> AsyncThrowingStream<Output, any Error> {
        resolve(with: session)
    }

    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `EndpointResolver` used to fetch the response.
    /// - returns: Some `Publisher`.
    @_spi(Private)
    func _resolve<R: EndpointResolver>(with session: R) -> AnyPublisher<Output, any Error> {
        resolve(with: session)
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

    /// Collect the first output and wrap
    /// it in a `SingleEndpoint`.
    ///
    /// - returns: Some `SingleEndpoint`.
    func first() -> First<Self> {
        .init { self }
    }

    /// Collect the final output and wrap
    /// it in a `SingleEndpoint`.
    ///
    /// - returns: Some `SingleEndpoint`.
    func last() -> Last<Self> {
        .init { self }
    }

    /// Collect all outputs and wrap
    /// them in a `SingleEndpoint`.
    ///
    /// - returns: Some `SingleEndpoint`.
    func collect() -> Collect<Self> {
        .init { self }
    }

    /// Collect up to `count` outputs.
    ///
    /// - parameter count: A valid `Int`.
    /// - returns: Some `LoopEndpoint`.
    func prefix(_ count: Int) -> Prefix<Self> {
        .init(count) { self }
    }
}
