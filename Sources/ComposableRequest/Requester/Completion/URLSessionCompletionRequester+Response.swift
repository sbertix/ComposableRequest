//
//  URLSessionCompletionRequester+Output.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

public extension URLSessionCompletionRequester {
    /// A `struct` defining the output for a `URLSessionCompletionRequester`.
    struct Response<Success>: URLSessionCompletionReceivable {
        /// The underlying request.
        private let request: Request

        /// The underlying task.
        ///
        /// Task is only ever `nil`, when the request was invalid.
        public let task: URLSessionDataTask?

        /// The delegate.
        public var handler: Handler

        /// Init.
        ///
        /// - parameters:
        ///     - request: A valid `Request`.
        ///     - task: An optional `URLSessionDataTask`.
        ///     - delegate: A valid `Delegate`.
        init(request: Request, task: URLSessionDataTask?, delegate: Handler) {
            self.request = request
            self.task = task
            self.handler = delegate
        }

        @discardableResult
        /// Resume.
        ///
        /// - returns: An optional `URLSessionDataTask`.
        public func resume() -> URLSessionDataTask? {
            guard let task = task else {
                // If there's no task you should still
                // notify it to the user.
                handler.completion?(.failure(Request.Error.invalidRequest(request)))
                return nil
            }
            task.resume()
            return task
        }
    }
}

public extension URLSessionCompletionRequester.Response {
    /// A `class` defining a data task delegate.
    final class Handler {
        /// The underlying completion.
        public var completion: ((Result<Success, Error>) -> Void)?

        /// Init.
        ///
        /// - parameters:
        ///     - transformer: A valid mapper.
        ///     - completion: An optional completion handler. Defaults to `nil`.
        public init(completion: ((Result<Success, Error>) -> Void)? = nil) {
            self.completion = completion
        }
    }
}
