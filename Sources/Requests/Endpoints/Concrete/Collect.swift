//
//  Collect.swift
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
/// reduced output of a loop endpoint.
public struct Collect<Parent: LoopEndpoint> {
    /// The associated output type.
    public typealias Output = [Parent.Output]

    /// The parent endpoint.
    private let parent: Parent

    /// Init.
    ///
    /// - parameter parent: A valid `Parent` factory.
    public init(@EndpointBuilder _ parent: () -> Parent) {
        self.parent = parent()
    }
}

extension Collect: SingleEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with session: URLSession) async throws -> Output {
        var responses: [Parent.Output] = []
        for try await response in parent.resolve(with: session) {
            responses.append(response)
        }
        return responses
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        parent.resolve(with: session)
            .collect()
            .eraseToAnyPublisher()
    }
    #endif
}
