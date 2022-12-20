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
    private let content: (_ offset: Int, _ input: Next) -> Content
    /// The next page mapper. Return `nil` to stop the stream.
    private let next: (_ offset: Int, _ output: Output) throws -> NextAction<Next>

    /// Init.
    ///
    /// - parameters:
    ///     - first: The starter `Next` for the pagination.
    ///     - request: The actual endpoint request.
    ///     - next: The next page mapper.
    public init(
        startingAt first: Next,
        @EndpointBuilder content: @escaping (_ offset: Int, _ input: Next) -> Content,
        next: @escaping (_ offset: Int, _ output: Output) throws -> NextAction<Next>
    ) {
        self.first = first
        self.content = content
        self.next = next
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
        next: @escaping (Output) throws -> NextAction<Next>
    ) {
        self.init(startingAt: first) {
            content($1)
        } next: {
            try next($1)
        }
    }
}

extension Loop: LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `EndpointResolver` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve<R: EndpointResolver>(with session: R) -> AsyncThrowingStream<Output, any Error> {
        // Hold reference to next input,
        // so we can paginate properly.
        let nextInput: NextInput<Next> = .init(first)
        return .init {
            // If next input is `nil`, cancel the stream.
            guard let input = await nextInput.value else { return nil }
            let offset = await nextInput.count
            let output = try await content(offset, input).resolve(with: session)
            // Update next input.
            switch try next(offset, output) {
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

    #if canImport(Combine)
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `EndpointResolver` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve<R: EndpointResolver>(with session: R) -> AnyPublisher<Output, any Error> {
        // Hold reference to next input,
        // so we can paginate properly.
        // swiftlint:disable:next private_subject
        let nextInput: CurrentValueSubject<(offset: Int, input: Next), any Error> = .init((0, first))
        return nextInput
            .flatMap(maxPublishers: .max(1)) { item in
                content(item.offset, item.input)
                    .resolve(with: session)
                    .prefix(1)
                    .handleEvents(receiveOutput: {
                        do {
                            // Switch depending on the
                            // next generated page.
                            switch try next(item.offset, $0) {
                            case .advance(let destination):
                                nextInput.send((item.offset + 1, destination))
                            case .repeat:
                                nextInput.send((item.offset + 1, item.input))
                            case .break:
                                nextInput.send(completion: .finished)
                            }
                        } catch {
                            nextInput.send(completion: .failure(error))
                        }
                    })
            }
            .eraseToAnyPublisher()
    }
    #endif
}
