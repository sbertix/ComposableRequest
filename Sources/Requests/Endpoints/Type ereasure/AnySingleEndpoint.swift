//
//  AnySingleEndpoint.swift
//  Requests
//
//  Created by Stefano Bertagno on 04/12/22.
//

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
    private let content: (URLSession) -> Task<Output, any Error>
    
    /// Init.
    ///
    /// - parameter endpoint: Some `SingleEndpoint`.
    public init<E: SingleEndpoint>(_ endpoint: E) where E.Output == Output {
        self.content = { session in .init { try await endpoint.resolve(with: session) }}
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
        try await content(session).value
    }
}
