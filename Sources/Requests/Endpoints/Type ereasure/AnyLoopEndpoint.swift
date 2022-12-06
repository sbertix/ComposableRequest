//
//  AnyLoopEndpoint.swift
//  Requests
//
//  Created by Stefano Bertagno on 04/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining a loop endpoint
/// erasing all its transformations and mapping,
/// similar to `AnyPublisher`.
///
/// If you are only targetting iOS 16, macOS 13,
/// tvOS 16 or watchOS 9 (and above), you can
/// possibly ignore this by returning
/// `some LoopEndpoint<Output>` on
/// construction.
public struct AnyLoopEndpoint<Output> {
    /// The stream factory.
    private let stream: (URLSession) -> AsyncThrowingStream<Output, any Error>
    /// The publisher factory.
    private let publisher: ((URLSession) -> Any)?

    /// Init.
    ///
    /// - parameter endpoint: A valid `AnyLoopEndpoint`.
    public init(_ endpoint: AnyLoopEndpoint<Output>) {
        self.stream = endpoint.stream
        self.publisher = endpoint.publisher
    }

    /// Init.
    ///
    /// - parameter endpoint: Some `LoopEndpoint`.
    public init<E: LoopEndpoint>(_ endpoint: E) where E.Output == Output {
        self.stream = { endpoint.resolve(with: $0) }
        #if canImport(Combine)
        self.publisher = { endpoint.resolve(with: $0) as AnyPublisher<Output, any Error> }
        #else
        self.publisher = nil
        #endif
    }
}

extension AnyLoopEndpoint: LoopEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        stream(session)
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
