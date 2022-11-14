//
//  Switch.swift
//  Core
//
//  Created by Stefano Bertagno on 16/11/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining an instance
/// transforming an endpoint response
/// into a different target.
public struct Switch<Parent: SingleEndpoint, Child: Endpoint>
where Child.Input == Parent.Output {
    /// The associated input type to generate request components.
    public typealias Input = Parent.Input
    /// The associated output type.
    public typealias Output = Child.Output

    /// The original endpoint.
    private let parent: Parent
    /// The child endpoint .
    private let child: Child

    /// Init.
    ///
    /// - parameters:
    ///     - parent: The parent endpoint.
    ///     - child: The child endpoint.
    public init(parent: Parent, child: Child) {
        self.parent = parent
        self.child = child
    }
}

extension Switch: Endpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - note:
    ///     You should prefer calling higher-level `protocol`s' `resolve` functions.
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    @_spi(Private) public func _resolve(with input: Input, _ session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        .init { continuation in
            Task {
                do {
                    let response = try await parent.resolve(with: input, session)
                    for try await output in child._resolve(with: response, session) {
                        continuation.yield(output)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

extension Switch: SingleEndpoint where Child: SingleEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with input: Input, _ session: URLSession) async throws -> Output {
        try await child.resolve(with: try await parent.resolve(with: input, session), session)
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
        parent.resolve(with: input, session)
            .flatMap { child.resolve(with: $0, session) }
            .eraseToAnyPublisher()
    }
    #endif
}

extension Switch: LoopEndpoint where Child: LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameters:
    ///     - input: Some `Input`.
    ///     - session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve(with input: Input, _ session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        _resolve(with: input, session)
    }
}
