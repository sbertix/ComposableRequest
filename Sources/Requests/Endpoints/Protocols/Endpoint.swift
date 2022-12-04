//
//  Endpoint.swift
//  Requests
//
//  Created by Stefano Bertagno on 02/11/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `protocol` defining an instance
/// targeting a single endpoint.
public protocol Endpoint<Output> {
    /// The associated output type.
    associatedtype Output

    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private)
    func _resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error>

    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `Publisher`.
    @_spi(Private)
    func _resolve(with session: URLSession) -> AnyPublisher<Output, any Error>
    #endif
}

public extension Endpoint {
    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `Publisher`.
    @_spi(Private)
    func _resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        // A passthrough subject used
        // to propagate responses.
        // swiftlint:disable:next private_subject
        let subject: PassthroughSubject<Output, any Error> = .init()
        Task {
            do {
                for try await response in _resolve(with: session) { subject.send(response) }
                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error))
            }
        }
        return subject.eraseToAnyPublisher()
    }
    #endif
}
