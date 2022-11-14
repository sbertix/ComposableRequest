//
//  Endpoint.swift
//  Core
//
//  Created by Stefano Bertagno on 02/11/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `protocol` defining an instance
/// targeting a single endpoint.
public protocol Endpoint<Input, Output> {
    /// The associated input type to generate request components.
    associatedtype Input: Sendable
    /// The associated output type.
    associatedtype Output

    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private) func _resolve(with input: Input, _ session: URLSession) -> AsyncThrowingStream<Output, any Error>

    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `Publisher`.
    @_spi(Private) func _resolve(with input: Input, _ session: URLSession) -> AnyPublisher<Output, any Error>
    #endif
}

public extension Endpoint {
    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `Publisher`.
    @_spi(Private) func _resolve(with input: Input, _ session: URLSession) -> AnyPublisher<Output, any Error> {
        // A passthrough subject used
        // to propagate responses.
        let subject: PassthroughSubject<Output, any Error> = .init()
        Task {
            do {
                for try await response in _resolve(with: input, session) { subject.send(response) }
                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error))
            }
        }
        return subject.eraseToAnyPublisher()
    }
    #endif
}
atom 
