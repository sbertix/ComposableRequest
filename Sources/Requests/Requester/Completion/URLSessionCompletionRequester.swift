//
//  URLSessionCompletionRequester.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 18/08/21.
//

import Foundation

/// A `struct` defining a concrete implementation of `Requester`
/// through _completion handlers_.
public struct URLSessionCompletionRequester {
    /// The requester input.
    public let input: Input

    /// Init.
    ///
    /// - parameter input: A valid `Input`.
    public init(_ input: Input) {
        self.input = input
    }

    /// Init.
    ///
    /// - parameters:
    ///     - session: A valid `URLSession`.
    ///     - logger: An optional `Logger`. Defaults to `.default`, meaning the default `Logger` will be used instead.
    /// - note:
    ///     We suggest custom implementation of `ComposableRequest` to implement
    ///     a custom `init` defaulting to their custom (or not) `URLSession`, and even
    ///     a static shared `default` instance.
    public init(session: URLSession,
                logger: Logger? = .default) {
        self.init(.init(session: session, logger: logger))
    }
}

extension URLSessionCompletionRequester: Requester {
    /// The associated output type.
    public typealias Output = Response<Request.Response>

    /// Prepare the request.
    ///
    /// - parameters:
    ///     - endpoint: A valid `Request`.
    ///     - requester: A valid `Self`.
    /// - returns: A valid `Output`.
    /// - note: This is implemented as a `static` function to hide its definition. Rely on `request.prepare(with:)` instead.
    public static func prepare(_ endpoint: Request, with requester: Self) -> Output {
        guard let request = Request.request(from: endpoint) else {
            return .init(request: endpoint, task: nil, delegate: .init())
        }
        let delegate = Output.Handler()
        requester.input.logger?.log(request)
        let task = requester.input.session.dataTask(with: request) { [weak delegate] data, response, error in
            if let error = error {
                requester.input.logger?.log(.failure(error))
                delegate?.completion?(.failure(error))
            } else if let data = data, let response = response {
                let result = Result<Request.Response, Error>.success(.init(data: data, response: response))
                requester.input.logger?.log(result)
                delegate?.completion?(result)
            }
        }
        return .init(request: endpoint, task: task, delegate: delegate)
    }
}

#if swift(>=5.5)
public extension Requester where Self == URLSessionCompletionRequester {
    /// Compose a completion requester.
    ///
    /// - parameter input: A valid `Input`.
    /// - returns: A valid `Self`.
    static func completion(_ input: Input) -> Self {
        .init(input)
    }

    /// Compose a completion requester.
    ///
    /// - parameters:
    ///     - session: A valid `URLSession`.
    ///     - logger: An optional `Logger`. Defaults to `.default`, meaning the default `Logger` will be used instead.
    /// - note:
    ///     We suggest custom implementation of `ComposableRequest` to implement
    ///     a custom `init` defaulting to their custom (or not) `URLSession`, and even
    ///     a static shared `default` instance.
    /// - returns: A valid `Self`.
    static func completion(session: URLSession, logger: Logger? = .default) -> Self {
        completion(.init(session: session, logger: logger))
    }
}
#endif
