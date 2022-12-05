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
    private let next: (Output) throws -> NextAction<Next>

    /// Init.
    ///
    /// - parameters:
    ///     - first: The starter `Next` for the pagination.
    ///     - request: The actual endpoint request.
    ///     - next: The next page mapper.
    public init(
        startingAt first: Next,
        @EndpointBuilder content: @escaping (Next) -> Content,
        next: @escaping (Output) throws -> NextAction<Next>
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
        next: @escaping (Output) throws -> NextAction<Next>
    ) where Next == T? {
        self.init(startingAt: nil, content: content, next: next)
    }

    /// Init.
    ///
    /// - parameters:
    ///     - first: The starter `Next` for the pagination.
    ///     - request: The actual endpoint request.
    ///     - next: The next page mapper.
    public init(
        startingAt first: Next,
        @EndpointBuilder content: @escaping (Next) -> Content,
        next: @escaping (Output) throws -> NextAction<Next>?
    ) {
        self.init(startingAt: first, content: content) {
            try next($0) ?? .break
        }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - request: The actual endpoint request.
    ///     - next: The next page mapper.
    public init<T>(
        @EndpointBuilder content: @escaping (Next) -> Content,
        next: @escaping (Output) throws -> NextAction<Next>?
    ) where Next == T? {
        self.init(content: content) {
            try next($0) ?? .break
        }
    }

    /// Init, by transforming a `SingleEndpoint`
    /// into a `Loop`, while still making sure it only
    /// returns once.
    ///
    /// - note: We do not provide an `EndpointBuilder` representation, to avoid `once` being omitted.
    /// - parameter single: Some `SingleEndpoint`.
    public init(once single: Content) where Next == Void {
        self.init(startingAt: (), content: { _ in single }, next: { _ in .break })
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
            switch try next(output) {
            case .advance(let destination):
                await nextInput.update(with: destination)
            case .repeat:
                await nextInput.update(with: input)
            case .break:
                await nextInput.update(with: nil)
            }
            return output
        }
    }
}
