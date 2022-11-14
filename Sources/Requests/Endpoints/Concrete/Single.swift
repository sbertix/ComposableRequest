//
//  Single.swift
//  Core
//
//  Created by Stefano Bertagno on 02/11/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining the basic instance
/// targeting a single API endpoint.
public struct Single<Input: Sendable, Output> {
    /// The request components builder.
    private let request: (Input) -> Components
    /// The response output mapper.
    private let response: (Data) throws -> Output

    /// Init.
    ///
    /// - parameters:
    ///     - request: The request component builder.
    ///     - response: The response output mapper.
    public init(
        @ComponentsBuilder request: @escaping (Input) -> Components,
        response: @escaping (Data) throws -> Output
    ) {
        self.request = request
        self.response = response
    }

    /// Init.
    ///
    /// - parameter request: The request component builder.
    public init(@ComponentsBuilder request: @escaping (Input) -> Components) where Output == Data {
        self.request = request
        self.response = { $0 }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: A valid `JSONDecoder`. Defaults to `.init`.
    ///     - request: The request component builder.
    public init(
        _ output: Output.Type,
        decoder: JSONDecoder = .init(),
        @ComponentsBuilder request: @escaping (Input) -> Components
    ) where Output: Decodable {
        self.request = request
        self.response = { try decoder.decode(output, from: $0) }
    }

    #if canImport(Combine)
    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: Some `TopLevelDecoder`.
    ///     - request: The request component builder.
    public init<D: TopLevelDecoder>(
        _ output: Output.Type,
        decoder: D,
        @ComponentsBuilder request: @escaping (Input) -> Components
    ) where Output: Decodable, D.Input == Data {
        self.request = request
        self.response = { try decoder.decode(output, from: $0) }
    }
    #endif
}

extension Single: SingleEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with input: Input, _ session: URLSession) async throws -> Output {
        guard let request = request(input).request else { throw EndpointError.invalidRequest }
        return try await response(session.data(for: request).0)
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with input: Input, _ session: URLSession) -> AnyPublisher<Output, any Error> {
        guard let request = request(input).request else {
            return Fail(error: EndpointError.invalidRequest)
                .eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .tryMap(response)
            .eraseToAnyPublisher()
    }
    #endif
}
