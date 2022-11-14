//
//  SingleEndpoint.swift
//  Core
//
//  Created by Stefano Bertagno on 14/11/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `protocol` defining an instance targeting
/// a single endpoint, incapable of pagination.
public protocol SingleEndpoint<Input, Output>: Endpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    func resolve(with input: Input, _ session: URLSession) async throws -> Output

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    func resolve(with input: Input, _ session: URLSession) -> AnyPublisher<Output, any Error>
    #endif
}

public extension SingleEndpoint {
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
            return try await resolve(with: input, session)
        }
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    func resolve(with input: Input, _ session: URLSession) -> AnyPublisher<Output, any Error> {
        _resolve(with: input, session).first().eraseToAnyPublisher()
    }
    #endif
}

public extension SingleEndpoint where Input == Void {
    /// Fetch the response, from a given `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    func resolve(with session: URLSession) async throws -> Output {
        try await resolve(with: (), session)
    }

    #if canImport(Combine)
    /// Fetch the response, from a given `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        resolve(with: (), session)
    }
    #endif
}

public extension SingleEndpoint where Output: Sendable {
    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    ///
    /// - parameter child: Some `Endpoint`.
    /// - returns: Some `Target.Switch`.
    func `switch`<T: Endpoint>(to child: T) -> Switch<Self, T> {
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
    func `switch`<O>(
        @ComponentsBuilder request: @escaping (Output) -> Components,
        response: @escaping (Data) throws -> O
    ) -> Switch<Self, Single<Output, O>> {
        self.switch(to: .init(request: request, response: response))
    }

    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    ///
    /// - parameter request: The request component builder.
    /// - returns: Some `Target.Switch`.
    func `switch`(
        @ComponentsBuilder request: @escaping (Output) -> Components
    ) -> Switch<Self, Single<Output, Data>> {
        self.switch(to: .init(request: request))
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
    func `switch`<O: Decodable>(
        _ output: O.Type,
        decoder: JSONDecoder = .init(),
        @ComponentsBuilder request: @escaping (Output) -> Components
    ) -> Switch<Self, Single<Output, O>> {
        self.switch(to: .init(output, decoder: decoder, request: request))
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
    func `switch`<O: Decodable, D: TopLevelDecoder>(
        _ output: O.Type,
        decoder: D,
        @ComponentsBuilder request: @escaping (Output) -> Components
    ) -> Switch<Self, Single<Output, O>> where D.Input == Data {
        self.switch(to: .init(output, decoder: decoder, request: request))
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
    func `switch`<O>(
        @ComponentsBuilder request: @escaping (Output) -> Components,
        response: @escaping (Data) throws -> O,
        page: @escaping (O) throws -> Output?
    ) -> Switch<Self, Loop<Output, O>> {
        self.switch(to: .init(request: request, response: response, page: page))
    }

    /// Switch the current endpoint response
    /// with a new one fetched from some other
    /// (related) endpoint.
    ///
    /// - parameters:
    ///     - request: The request component builder.
    ///     - page: The next page mapper.
    /// - returns: Some `Target.Switch`.
    func `switch`(
        @ComponentsBuilder request: @escaping (Output) -> Components,
        page: @escaping (Data) throws -> Output?
    ) -> Switch<Self, Loop<Output, Data>> {
        self.switch(to: .init(request: request, page: page))
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
    func `switch`<O: Decodable>(
        _ output: O.Type,
        decoder: JSONDecoder = .init(),
        @ComponentsBuilder request: @escaping (Output) -> Components,
        page: @escaping (O) throws -> Output?
    ) -> Switch<Self, Loop<Output, O>> {
        self.switch(to: .init(output, decoder: decoder, request: request, page: page))
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
    func `switch`<O: Decodable, D: TopLevelDecoder>(
        _ output: O.Type,
        decoder: D,
        @ComponentsBuilder request: @escaping (Output) -> Components,
        page: @escaping (O) throws -> Output?
    ) -> Switch<Self, Loop<Output, O>> where D.Input == Data {
        self.switch(to: .init(output, decoder: decoder, request: request, page: page))
    }
    #endif
}
