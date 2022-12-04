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
public struct Response<Output> {
    /// The content factory.
    let content: (_ response: URLResponse, _ data: Data) throws -> Output
    
    /// Init.
    ///
    /// - parameter content: A valid content factory.
    public init(_ content: @escaping (_ response: URLResponse, _ data: Data) throws -> Output) {
        self.content = content
    }
    
    /// Init.
    ///
    /// - parameter content: A simplified content factory, only accounting for the actual output.
    public init(_ content: @escaping (Data) throws -> Output) {
        self.init { try content($1) }
    }
    
    /// Init.
    ///
    /// - parameters:
    ///     - output: The `Output` type.
    ///     - decoder: A valid `JSONDecoder`. Defaults to `.init`.
    public init(
        _ output: Output.Type,
        decoder: JSONDecoder = .init()
    ) where Output: Decodable {
        self.init { try decoder.decode(output, from: $0) }
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
    ) where Output: Decodable, D.Input == Data {
        self.init { try decoder.decode(output, from: $0) }
    }
    #endif
}
