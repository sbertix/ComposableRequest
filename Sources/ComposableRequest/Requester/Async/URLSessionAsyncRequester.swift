//
//  URLSessionAsyncRequester.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 18/08/21.
//

#if swift(>=5.5)
import Foundation

/// A `struct` defining a concrete implementation of `Requester`
/// through _structured cuncurrency_.
@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public struct URLSessionAsyncRequester {
    /// The associated input.
    public let input: Input

    /// Init.
    ///
    /// - parameter input: A valid `Input`.
    public init(_ input: Input) {
        self.input = input
    }

    /// Compose an async requester.
    ///
    /// - parameters:
    ///     - session: A valid `URLSession`.
    ///     - priority: An optional `TaskPriority`. Defaults to `nil`.
    ///     - logger: An optional `Logger`. Defaults to `.default`, meaning the default `Logger` will be used instead.
    /// - note:
    ///     We suggest custom implementation of `ComposableRequest` to implement
    ///     a custom `init` defaulting to their custom (or not) `URLSession`, and even
    ///     a static shared `default` instance.
    public init(session: URLSession,
                priority: TaskPriority? = nil,
                logger: Logger? = .default) {
        self.init(.init(session: session, priority: priority, logger: logger))
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension URLSessionAsyncRequester: Requester {
    /// The associated output type.
    public typealias Output = Response<Request.Response>

    /// Prepare the request.
    ///
    /// - parameters:
    ///     - request: A valid `Request`.
    ///     - requester: A valid `Self`.
    /// - returns: A valid `Output`.
    /// - note: This is implemented as a `static` function to hide its definition. Rely on `request.prepare(with:)` instead.
    public static func prepare(_ request: Request, with requester: Self) -> Output {
        .init(priority: requester.input.priority) { () throws -> Request.Response in
            guard let request = Request.request(from: request) else { throw Request.Error.invalidRequest(request) }
            let response = try await requester.input.session.data(for: request)
            return .init(data: response.0, response: response.1)
        }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public extension Requester where Self == URLSessionAsyncRequester {
    /// Compose an async requester.
    ///
    /// - parameter input: A valid `Input`.
    /// - returns: A valid `Self`.
    static func `async`(_ input: Input) -> Self {
        .init(input)
    }

    /// Compose an async requester.
    ///
    /// - parameters:
    ///     - session: A valid `URLSession`.
    ///     - priority: An optional `TaskPriority`. Defaults to `nil`.
    ///     - logger: An optional `Logger`. Defaults to `.default`, meaning the default `Logger` will be used instead.
    /// - note:
    ///     We suggest custom implementation of `ComposableRequest` to implement
    ///     a custom `init` defaulting to their custom (or not) `URLSession`, and even
    ///     a static shared `default` instance.
    /// - returns: A valid `Self`.
    static func `async`(session: URLSession,
                        priority: TaskPriority? = nil,
                        logger: Logger? = .default) -> Self {
        async(.init(session: session, priority: priority, logger: logger))
    }
}
#endif
