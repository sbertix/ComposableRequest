//
//  URLSessionCombineRequester.swift
//  ComposableRequester
//
//  Created by Stefano Bertagno on 18/08/21.
//

#if canImport(Combine)
import Combine
import Foundation

/// A `struct` defining a concrete implementation of `Requester` with **Combine**.
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public struct URLSessionCombineRequester {
    /// The requester input.
    public let input: Input

    /// Init.
    ///
    /// - parameter input: A valid `Input`.
    public init(_ input: Input) {
        self.input = input
    }

    /// Compose a combine requester.
    ///
    /// - parameters:
    ///     - session: A valid `URLSession`.
    ///     - retries: A valid `Int`. Defaults to `0`.
    ///     - logger: An optional `Logger`. Defaults to `.default`, meaning the default `Logger` will be used instead.
    /// - note:
    ///     We suggest custom implementation of `ComposableRequest` to implement
    ///     a custom `init` defaulting to their custom (or not) `URLSession`, and even
    ///     a static shared `default` instance.
    public init(session: URLSession,
                retries: Int = 0,
                logger: Logger? = .default) {
        self.init(.init(session: session, retries: retries, logger: logger))
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension URLSessionCombineRequester: Requester {
    /// The associated output type.
    public typealias Output = Response<Request.Response>

    /// Prepare the request.
    ///
    /// - parameters:
    ///     - request: A valid `Request`.
    ///     - requester: A valid `Self`.
    /// - returns: A valid `Output`.
    /// - note: This is implemented as a `static` function to hide its definition. Rely on `request.prepare(with:)` instead.
    public static func prepare(_ endpoint: Request, with requester: Self) -> Output {
        .init(publisher: Just(endpoint)
                .setFailureType(to: Error.self)
                .tryMap { request throws -> URLRequest in
                    guard let request = Request.request(from: request) else {
                        throw Request.Error.invalidRequest(endpoint)
                    }
                    return request
                }
                .flatMap { request in
                    requester.input.session
                        .dataTaskPublisher(for: request)
                        .retry(requester.input.retries)
                        .map(Request.Response.init)
                        .catch { Fail(error: $0 as Error) }
                        .handleEvents(receiveSubscription: { _ in requester.input.logger?.log(request) },
                                      receiveOutput: { requester.input.logger?.log(.success($0)) },
                                      receiveCompletion: {
                            if case .failure(let error) = $0 {
                                requester.input.logger?.log(.failure(error))
                            }
                        })
                })
    }
}

#if swift(>=5.5)
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public extension Requester where Self == URLSessionCombineRequester {
    /// Compose a combine requester.
    ///
    /// - parameter input: A valid `Input`.
    /// - returns: A valid `Self`.
    static func combine(_ input: Input) -> Self {
        .init(input)
    }

    /// Compose a combine requester.
    ///
    /// - parameters:
    ///     - session: A valid `URLSession`.
    ///     - retries: A valid `Int`. Defaults to `0`.
    ///     - logger: An optional `Logger`. Defaults to `.default`, meaning the default `Logger` will be used instead.
    /// - note:
    ///     We suggest custom implementation of `ComposableRequest` to implement
    ///     a custom `init` defaulting to their custom (or not) `URLSession`, and even
    ///     a static shared `default` instance.
    /// - returns: A valid `Self`.
    static func combine(session: URLSession,
                        retries: Int = 0,
                        logger: Logger? = .default) -> Self {
        combine(.init(session: session, retries: retries, logger: logger))
    }
}
#endif
#endif
