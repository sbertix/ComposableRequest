//
//  Future.swift
//  Requests
//
//  Created by Stefano Bertagno on 13/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining some external
/// value to appear inside an endpoint
/// chain (e.g. returning a single value,
/// returning an error, etc) at a future time.
public struct Future<Output> {
    /// The underlying content factory.
    let content: () async throws -> Output

    /// Init.
    ///
    /// - parameter content: The content factory.
    public init(_ content: @escaping () async throws -> Output) {
        self.content = content
    }
}

extension Future: SingleEndpoint {
    /// Resolve the current endpoint.
    ///
    /// - parameter session: A valid `URLSession`.
    /// - throws: Any `Error`.
    /// - returns: Some `Output`.
    public func resolve(with session: URLSession) async throws -> Output {
        try await content()
    }
}
