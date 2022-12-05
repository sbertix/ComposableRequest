//
//  Single.swift
//  Requests
//
//  Created by Stefano Bertagno on 04/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining a custom endpoint
/// implementation handling a single request.
public struct Single<Output> {
    /// The endpoint path.
    let path: String
    /// The components.
    var components: [ObjectIdentifier: any Component]
    /// The response.
    let output: (DefaultResponse) throws -> Output

    /// Init.
    ///
    /// - parameters:
    ///     - path: A valid `String`.
    ///     - components: A valid `Component` dictionary.
    ///     - output: A valid output factory.
    init(
        path: String,
        components: [ObjectIdentifier: any Component],
        output: @escaping (DefaultResponse) throws -> Output
    ) {
        self.path = path
        self.components = components
        self.output = output
    }

    /// Init.
    ///
    /// - parameter content: A valid `Single` factory.
    public init(@EndpointBuilder content: () -> Single) {
        self = content()
    }
}

extension Single: SingleEndpoint {
    /// Resolve the current endpoint.
    ///
    /// - parameter session: A valid `URLSession`.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with session: URLSession) async throws -> Output {
        guard let request = URLRequest(path: path, components: components) else { throw EndpointError.invalidRequest }
        let (data, response) = try await session._data(for: request)
        return try output(.init(response: response, data: data))
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        guard let request = URLRequest(path: path, components: components) else {
            return Fail(error: EndpointError.invalidRequest)
                .eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: request)
            .tryMap { try output(.init(response: $0.response, data: $0.data)) }
            .eraseToAnyPublisher()
    }
    #endif
}
