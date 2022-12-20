//
//  AnyEndpointResolver.swift
//  Requests
//
//  Created by Stefano Bertagno on 20/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining an endpoint resolver
/// erasing its identity (i.e. `Self`-associated
/// values), similar to `AnyPublisher`.
public struct AnyEndpointResolver {
    /// The task factory.
    private let task: (URLRequest) async throws -> DefaultResponse
    /// The publisher factory.
    private let publisher: ((URLRequest) -> Any)?

    /// Init.
    ///
    /// - parameter session: A valid `AnyEndpointResolver`.
    public init(_ session: AnyEndpointResolver) {
        self.task = session.task
        self.publisher = session.publisher
    }

    /// Init.
    ///
    /// - parameter session: Some `EndpointResolver`.
    public init<R: EndpointResolver>(_ session: R) {
        self.task = { try await session.resolve($0) }
        #if canImport(Combine)
        self.publisher = { session.resolve($0) as AnyPublisher<DefaultResponse, any Error> }
        #else
        self.publisher = nil
        #endif
    }
}

extension AnyEndpointResolver: EndpointResolver {
    /// Compose the `DefaultResponse`.
    ///
    /// - throws: Any `Error`.
    /// - returns: Some `DefaultResponse`.
    @_spi(Private)
    public func resolve(_ request: URLRequest) async throws -> DefaultResponse {
        try await task(request)
    }

    #if canImport(Combine)
    /// Compose the `DefaultResponse`.
    ///
    /// - throws: Any `Error`.
    /// - returns: Some `DefaultResponse` publisher.
    @_spi(Private)
    public func resolve(_ request: URLRequest) -> AnyPublisher<DefaultResponse, any Error> {
        guard let publisher = publisher?(request) as? AnyPublisher<DefaultResponse, any Error> else {
            return Fail(error: EndpointError.invalidPublisherType).eraseToAnyPublisher()
        }
        return publisher
    }
    #endif
}
