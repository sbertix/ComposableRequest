//
//  AnySingleEndpoint.swift
//  Requests
//
//  Created by Stefano Bertagno on 04/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining a single endpoint
/// erasing all its transformations and mapping,
/// similar to `AnyPublisher`.
///
/// If you are only targetting iOS 16, macOS 13,
/// tvOS 16 or watchOS 9 (and above), you can
/// possibly ignore this by returning
/// `some SingleEndpoint<Output>` on
/// construction.
public struct AnySingleEndpoint<Output> {
    /// The task factory.
    private let task: (URLSession) async throws -> Output
    /// The publisher factory.
    private let publisher: ((URLSession) -> Any)?

    /// Init.
    ///
    /// - parameter endpoint: A valid `AnySingleEndpoint`.
    public init(_ endpoint: AnySingleEndpoint<Output>) {
        self.task = endpoint.task
        self.publisher = endpoint.publisher
    }

    /// Init.
    ///
    /// - parameter endpoint: Some `SingleEndpoint`.
    public init<E: SingleEndpoint>(_ endpoint: E) where E.Output == Output {
        self.task = { try await endpoint.resolve(with: $0) }
        #if canImport(Combine)
        self.publisher = { endpoint.resolve(with: $0) as AnyPublisher<Output, any Error> }
        #else
        self.publisher = nil
        #endif
    }
}

extension AnySingleEndpoint: SingleEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with session: URLSession) async throws -> Output {
        try await task(session)
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        guard let publisher = publisher?(session) as? AnyPublisher<Output, any Error> else {
            return Fail(error: EndpointError.invalidPublisherType).eraseToAnyPublisher()
        }
        return publisher
    }
    #endif
}
