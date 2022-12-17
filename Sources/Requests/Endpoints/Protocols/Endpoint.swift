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

import Storages

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
    /// Map the output to some convenience value.
    ///
    /// - parameter content: A valid content factory.
    /// - returns: Some `Endpoint`.
    func map<O>(_ content: @escaping (Output) throws -> O) -> Map<Self, O> {
        .init({ self }, to: content)
    }

    /// Catch the error and compose a new endpoint.
    ///
    /// - parameter content: A valid content factory.
    /// - returns: Some `Endpoint`.
    func `catch`<S: SingleEndpoint>(
        @EndpointBuilder _ content: @escaping (any Error) -> S
    ) -> Catch<Self, S> {
        .init({ self }, to: content)
    }

    /// Store an item into the appropriate storage.
    ///
    /// - parameter storage: Some `Storage`.
    /// - returns: Some `Endpoint`.
    func store<S: Storage>(in storage: S) -> Map<Self, Output> where S.Item == Output {
        map { try storage.insert($0); return $0 }
    }
}
