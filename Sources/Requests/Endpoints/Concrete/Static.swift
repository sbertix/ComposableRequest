//
//  Static.swift
//  Requests
//
//  Created by Stefano Bertagno on 05/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining some external
/// value to appear inside an endpoint
/// chain (e.g. returning a single value,
/// returning an error, etc).
public struct Static<Output> {
    /// The underlying value.
    let content: Result<Output, any Error>

    /// Init.
    ///
    /// - parameter content: The content factory.
    public init(_ content: () throws -> Output) {
        self.content = Result(catching: content)
    }

    /// Init.
    ///
    /// - parameter output: A single output.
    public init(_ output: Output) {
        self.content = .success(output)
    }

    /// Init.
    ///
    /// - parameter error: A single error.
    public init(error: any Error) {
        self.content = .failure(error)
    }
}

extension Static: SingleEndpoint {
    /// Resolve the current endpoint.
    ///
    /// - parameter session: A valid `URLSession`.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with session: URLSession) async throws -> Output {
        try content.get()
    }

    #if canImport(Combine)
    /// Fetch the response, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AnyPublisher`.
    public func resolve(with session: URLSession) -> AnyPublisher<Output, any Error> {
        content.publisher.eraseToAnyPublisher()
    }
    #endif
}
