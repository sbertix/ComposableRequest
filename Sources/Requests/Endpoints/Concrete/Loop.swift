//
//  Loop.swift
//  Core
//
//  Created by Stefano Bertagno on 14/11/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining the basic instance
/// targeting a single paginated API endpoint.
public struct Loop<Input: Sendable, Output> {
    /// The request components builder.
    private let request: (Input) -> Components
    /// The response output mapper.
    private let response: (Data) throws -> Output
    /// The next page mapper. Return `nil` to stop the stream.
    private let page: (Output) throws -> Input?

    /// Init.
    ///
    /// - parameters:
    ///     - request: The request component builder.
    ///     - response: The response output mapper.
    ///     - page: The next page mapper.
    public init(
        @ComponentsBuilder request: @escaping (Input) -> Components,
        response: @escaping (Data) throws -> Output,
        page: @escaping (Output) throws -> Input?
    ) {
        self.request = request
        self.response = response
        self.page = page
    }

    /// Init.
    ///
    /// - parameters:
    ///     - request: The request component builder.
    ///     - page: The next page mapper.
    public init(
        @ComponentsBuilder request: @escaping (Input) -> Components,
        page: @escaping (Output) throws -> Input?
    ) where Output == Data {
        self.request = request
        self.response = { $0 }
        self.page = page
    }

    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: A valid `JSONDecoder`. Defaults to `.init`.
    ///     - request: The request component builder.
    ///     - page: The next page mapper.
    public init(
        _ output: Output.Type,
        decoder: JSONDecoder = .init(),
        @ComponentsBuilder request: @escaping (Input) -> Components,
        page: @escaping (Output) throws -> Input?
    ) where Output: Decodable {
        self.request = request
        self.response = { try decoder.decode(output, from: $0) }
        self.page = page
    }

    #if canImport(Combine)
    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: Some `TopLevelDecoder`.
    ///     - request: The request component builder.
    ///     - page: The next page mapper.
    public init<D: TopLevelDecoder>(
        _ output: Output.Type,
        decoder: D,
        @ComponentsBuilder request: @escaping (Input) -> Components,
        page: @escaping (Output) throws -> Input?
    ) where Output: Decodable, D.Input == Data {
        self.request = request
        self.response = { try decoder.decode(output, from: $0) }
        self.page = page
    }
    #endif
}

extension Loop: LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve(with input: Input, _ session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        // Hold reference to next input,
        // so we can paginate properly.
        let nextInput: NextInput<Input> = .init(input)
        return .init {
            // If next input is `nil`, cancel the stream.
            guard let input = await nextInput.value else { return nil }
            guard let request = request(input).request else { throw EndpointError.invalidRequest }
            let output = try await response(session.data(for: request).0)
            // Update last input.
            await nextInput.update(with: try page(output))
            return output
        }
    }
}
