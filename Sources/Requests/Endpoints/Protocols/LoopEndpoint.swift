//
//  LoopEndpoint.swift
//  Core
//
//  Created by Stefano Bertagno on 15/11/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `protocol` defining an instance targeting
/// a single endpoint, capable of pagination.
public protocol LoopEndpoint<Input, Output>: Endpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    func resolve(with input: Input, _ session: URLSession) -> AsyncThrowingStream<Output, any Error>

    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `Publisher`.
    func resolve(with input: Input, _ session: URLSession) -> AnyPublisher<Output, any Error>
    #endif
}

public extension LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private) func _resolve(with input: Input, _ session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        resolve(with: input, session)
    }

    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `Publisher`.
    func resolve(with input: Input, _ session: URLSession) -> AnyPublisher<Output, any Error> {
        _resolve(with: input, session)
    }
    #endif
}

public extension LoopEndpoint where Input == Void {
    /// Fetch responses, from a given `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    func resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        resolve(with: (), session)
    }

    #if canImport(Combine)
    /// Fetch responses, from a given `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `Publisher`.
    func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        resolve(with: (), session)
    }
    #endif
}

public extension LoopEndpoint where Output: Sendable {
    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    ///
    /// - parameter child: Some `Endpoint`.
    /// - returns: Some `Target.Switch`.
    func collect<T: Endpoint>(to child: T) -> Collect<Self, T> {
        .init(parent: self, child: child)
    }

    // MARK: Single

    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    ///
    /// - parameters:
    ///     - request: The request component builder.
    ///     - response: The response output mapper.
    /// - returns: Some `Target.Switch`.
    func collect<O>(
        @ComponentsBuilder request: @escaping ([Output]) -> Components,
        response: @escaping (Data) throws -> O
    ) -> Collect<Self, Single<[Output], O>> {
        self.collect(to: .init(request: request, response: response))
    }

    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    ///
    /// - parameter request: The request component builder.
    /// - returns: Some `Target.Switch`.
    func collect(
        @ComponentsBuilder request: @escaping ([Output]) -> Components
    ) -> Collect<Self, Single<[Output], Data>> {
        self.collect(to: .init(request: request))
    }

    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: A valid `JSONDecoder`. Defaults to `.init`.
    ///     - request: The request component builder.
    func collect<O: Decodable>(
        _ output: O.Type,
        decoder: JSONDecoder = .init(),
        @ComponentsBuilder request: @escaping ([Output]) -> Components
    ) -> Collect<Self, Single<[Output], O>> {
        self.collect(to: .init(output, decoder: decoder, request: request))
    }

    #if canImport(Combine)
    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: Some `TopLevelDecoder`.
    ///     - request: The request component builder.
    func collect<O: Decodable, D: TopLevelDecoder>(
        _ output: O.Type,
        decoder: D,
        @ComponentsBuilder request: @escaping ([Output]) -> Components
    ) -> Collect<Self, Single<[Output], O>> where D.Input == Data {
        self.collect(to: .init(output, decoder: decoder, request: request))
    }
    #endif

    // MARK: Loop

    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    ///
    /// - parameters:
    ///     - request: The request component builder.
    ///     - response: The response output mapper.
    ///     - page: The next page mapper.
    /// - returns: Some `Target.Switch`.
    func collect<O>(
        @ComponentsBuilder request: @escaping ([Output]) -> Components,
        response: @escaping (Data) throws -> O,
        page: @escaping (O) throws -> [Output]?
    ) -> Collect<Self, Loop<[Output], O>> {
        self.collect(to: .init(request: request, response: response, page: page))
    }

    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    ///
    /// - parameters:
    ///     - request: The request component builder.
    ///     - page: The next page mapper.
    /// - returns: Some `Target.Switch`.
    func collect(
        @ComponentsBuilder request: @escaping ([Output]) -> Components,
        page: @escaping (Data) throws -> [Output]?
    ) -> Collect<Self, Loop<[Output], Data>> {
        self.collect(to: .init(request: request, page: page))
    }

    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: A valid `JSONDecoder`. Defaults to `.init`.
    ///     - request: The request component builder.
    ///     - page: The next page mapper.
    func collect<O: Decodable>(
        _ output: O.Type,
        decoder: JSONDecoder = .init(),
        @ComponentsBuilder request: @escaping ([Output]) -> Components,
        page: @escaping (O) throws -> [Output]?
    ) -> Collect<Self, Loop<[Output], O>> {
        self.collect(to: .init(output, decoder: decoder, request: request, page: page))
    }

    #if canImport(Combine)
    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: Some `TopLevelDecoder`.
    ///     - request: The request component builder.
    ///     - page: The next page mapper.
    func collect<O: Decodable, D: TopLevelDecoder>(
        _ output: O.Type,
        decoder: D,
        @ComponentsBuilder request: @escaping ([Output]) -> Components,
        page: @escaping (O) throws -> [Output]?
    ) -> Collect<Self, Loop<[Output], O>> where D.Input == Data {
        self.collect(to: .init(output, decoder: decoder, request: request, page: page))
    }
    #endif
}
