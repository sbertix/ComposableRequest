//
//  AnyLoopEndpoint.swift
//  Requests
//
//  Created by Stefano Bertagno on 04/12/22.
//

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
    /// The task factory.
    private let content: (URLSession) -> AsyncThrowingStream<Output, any Error>

    /// Init.
    ///
    /// - parameter endpoint: Some `LoopEndpoint`.
    public init<E: LoopEndpoint>(_ endpoint: E) where E.Output == Output {
        self.content = { session in endpoint.resolve(with: session) }
    }
}

extension AnyLoopEndpoint: LoopEndpoint {
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        content(session)
    }
}
