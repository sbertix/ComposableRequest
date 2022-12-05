//
//  Response.swift
//  Core
//
//  Created by Stefano Bertagno on 04/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining the response
/// transformation.
public struct Response<Input, Output> {
    /// The content factory.
    let content: (Input) throws -> Output

    /// Init.
    ///
    /// - parameter content: A valid content factory.
    public init(_ content: @escaping (Input) throws -> Output) {
        self.content = content
    }

    /// Init.
    ///
    /// - parameter content: A simplified content factory, only accounting for the actual output.
    public init(_ content: @escaping (Data) throws -> Output) where Input == DefaultResponse {
        self.init { try content($0.data) }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: A valid `JSONDecoder`. Defaults to `.init`.
    public init(
        _ output: Output.Type,
        decoder: JSONDecoder = .init()
    ) where Input == DefaultResponse, Output: Decodable {
        self.init { try decoder.decode(output, from: $0.data) }
    }

    #if canImport(Combine)
    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: Some `TopLevelDecoder`.
    public init<D: TopLevelDecoder>(
        _ output: Output.Type,
        decoder: D
    ) where Input == DefaultResponse, Output: Decodable, D.Input == Data {
        self.init { try decoder.decode(output, from: $0.data) }
    }
    #endif
}
