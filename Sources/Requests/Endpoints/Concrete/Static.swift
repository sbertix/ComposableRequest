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
    /// The content factory.
    let content: () async throws -> Output

    /// Init.
    ///
    /// - parameter content: The content factory.
    public init(_ content: @escaping () async throws -> Output) {
        self.content = content
    }

    /// Init.
    ///
    /// - parameter output: A single output.
    public init(_ output: Output) {
        self.content = { output }
    }

    /// Init.
    ///
    /// - parameter error: A single error.
    public init(error: any Error) {
        self.content = { throw error }
    }
}

extension Static: SingleEndpoint {
    /// Resolve the current endpoint.
    ///
    /// - parameter session: A valid `URLSession`.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with session: URLSession) async throws -> Output {
        try await content()
    }
}
