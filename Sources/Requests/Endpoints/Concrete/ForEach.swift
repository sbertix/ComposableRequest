//
//  ForEach.swift
//  Requests
//
//  Created by Stefano Bertagno on 08/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `struct` defining a custom endpoint
/// implementation handling a sequence of
/// requests.
public struct ForEach<Next: Sendable, Content: SingleEndpoint> {
    /// The associated output type.
    public typealias Output = Content.Output

    /// Th endpoint pagination.
    private let pages: [Next]
    /// The actual endpoint request.
    private let content: (_ offset: Int, _ input: Next) -> Content

    /// Init.
    ///
    /// - parameters:
    ///     - pages: The collection of pages.
    ///     - content: The actual endpoint request.
    public init<C: Collection>(
        _ pages: C,
        @EndpointBuilder content: @escaping (_ offset: Int, _ input: Next) -> Content
    ) where C.Element == Next {
        self.pages = .init(pages)
        self.content = content
    }

    /// Init.
    ///
    /// - parameters:
    ///     - pages: The collection of pages.
    ///     - content: The actual endpoint request.
    public init<C: Collection>(
        _ pages: C,
        @EndpointBuilder content: @escaping (Next) -> Content
    ) where C.Element == Next {
        self.init(pages) { content($1) }
    }
}

extension ForEach: LoopEndpoint {
    /// Fetch responses, from a given
    /// `Input` and `URLSession`.
    ///
    /// - parameter session: The `EndpointResolver` used to fetch the response.
    /// - returns: Some `AsyncStream`.
    public func resolve<R: EndpointResolver>(with session: R) -> AsyncThrowingStream<Output, any Error> {
        // Hold reference to next input,
        // so we can paginate properly.
        let nextInput: NextInput<Int> = .init(0)
        return .init {
            // If next input is `nil`, cancel the stream.
            guard let offset = await nextInput.value, offset < pages.count else { return nil }
            let output = try await content(offset, pages[offset]).resolve(with: session)
            await nextInput.update(with: offset + 1)
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
        let nextInput: CurrentValueSubject<Int, any Error> = .init(0)
        return nextInput
            .prefix { [count = pages.count] in $0 < count }
            .flatMap(maxPublishers: .max(1)) { offset in
                content(offset, pages[offset])
                    .resolve(with: session)
                    .prefix(1)
                    .handleEvents(receiveOutput: { _ in nextInput.send(offset + 1) })
            }
            .eraseToAnyPublisher()
    }
    #endif
}
