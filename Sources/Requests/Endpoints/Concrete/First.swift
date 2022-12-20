//
//  First.swift
//  Requests
//
//  Created by Stefano Bertagno on 07/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining a custom endpoint
/// implementation returning a wrapper for the
/// first output of a loop endpoint.
public struct First<Parent: LoopEndpoint> {
    /// The associated output type.
    public typealias Output = Parent.Output

    /// The parent endpoint.
    private let parent: Parent

    /// Init.
    ///
    /// - parameter parent: A valid `Parent` factory.
    public init(@EndpointBuilder _ parent: () -> Parent) {
        self.parent = parent()
    }
}

extension First: SingleEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `EndpointResolver` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve<R: EndpointResolver>(with session: R) async throws -> Output {
        for try await response in parent.resolve(with: session).prefix(1) {
            // Return immediately after
            // the first response.
            return response
        }
        throw EndpointError.emptyStream
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `EndpointResolver` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve<R: EndpointResolver>(with session: R) -> AnyPublisher<Output, any Error> {
        parent.resolve(with: session)
            .first()
            .eraseToAnyPublisher()
    }
    #endif
}
