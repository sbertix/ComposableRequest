//
//  Loop.swift
//  Requests
//
//  Created by Stefano Bertagno on 04/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining a custom endpoint
/// implementation handling a paginated request.
public struct Loop<Next: Sendable, Content: SingleEndpoint> {
    /// The associated output type.
    public typealias Output = Content.Output
    
    /// The initial page value.
    private let first: Next
    /// The actual endpoint request.
    private let content: (Next) -> Content
    /// The next page mapper. Return `nil` to stop the stream.
    private let next: (Output) throws -> Next?

    /// Init.
    ///
    /// - parameters:
    ///     - first: The starter `Next` for the pagination.
    ///     - request: The actual endpoint request.
    ///     - next: The next page mapper.
    public init(
        startingAt first: Next,
        @EndpointBuilder content: @escaping (Next) -> Content,
        next: @escaping (Output) throws -> Next?
    ) {
        self.first = first
        self.content = content
        self.next = next
    }
    
    /// Init.
    ///
    /// - parameters:
    ///     - request: The actual endpoint request.
    ///     - next: The next page mapper.
    public init<T>(
        @EndpointBuilder content: @escaping (Next) -> Content,
        next: @escaping (Output) throws -> Next?
    ) where Next == T? {
        self.first = nil
        self.content = content
        self.next = next
    }
}

extension Loop: LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `URLSession` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve(with session: URLSession) -> AsyncThrowingStream<Output, any Error> {
        // Hold reference to next input,
        // so we can paginate properly.
        let nextInput: NextInput<Next> = .init(first)
        return .init {
            // If next input is `nil`, cancel the stream.
            guard let input = await nextInput.value else { return nil }
            let output = try await content(input).resolve(with: session)
            // Update last input.
            await nextInput.update(with: try next(output))
            return output
        }
    }
}
