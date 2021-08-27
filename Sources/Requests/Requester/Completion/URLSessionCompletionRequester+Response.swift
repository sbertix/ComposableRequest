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
        /// The underlying value.
        public let value: URLSessionCompletionValue
        /// The delegate.
        public var handler: Handler

        /// The underlying response.
        public var response: URLSessionCompletionRequester.Response<Success> {
            self
        }

        /// Init.
        ///
        /// - parameters:
        ///     - value: A valid `URLSessionCompletionValue`.
        ///     - handler: A valid `Handler`.
        public init(value: URLSessionCompletionValue, handler: Handler) {
            self.value = value
            self.handler = handler
        }

        /// Init.
        ///
        /// - parameter request: A valid `Request`.
        public init(invalidRequest request: Request) {
            self.init(value: .invalidRequest(request), handler: .init())
        }

        /// Init.
        ///
        /// - parameters:
        ///     - task: A valid `URLSessionDataTask`.
        ///     - handler: A valid `Handler`.
        public init(task: URLSessionDataTask, handler: Handler) {
            self.init(value: .task(task), handler: handler)
        }

        @discardableResult
        /// Resume.
        ///
        /// - returns: An optional `URLSessionDataTask`.
        public func resume() -> URLSessionDataTask? {
            switch value {
            case .invalidRequest(let request):
                // If there's no task you should still
                // notify it to the user.
                handler.completion?(.failure(Request.Error.invalidRequest(request)))
                return nil
            case .task(let task):
                task.resume()
                return task
            }
        }

        /// Flat map the current task.
        ///
        /// - parameter mapper: A valid mapper.
        /// - returns: Some `URLSessionCompletionReceivable`.
        func chain<S>(_ mapper: @escaping (Result<Success, Error>) -> Result<S, Error>) -> URLSessionCompletionRequester.Response<S> {
            let handler = URLSessionCompletionRequester.Response<S>.Handler()
            self.handler.completion = { handler.completion?(mapper($0)) }
            return .init(value: value, handler: handler)
        }

        /// Flat map the current task.
        ///
        /// - parameter mapper: A valid mapper.
        /// - returns: Some `URLSessionCompletionReceivable`.
        func chain<S>(_ mapper: @escaping (Success) -> Result<S, Error>) -> URLSessionCompletionRequester.Response<S> {
            chain { (result: Result<Success, Error>) in result.flatMap(mapper) }
        }

        /// Flat map the current task.
        ///
        /// - parameter mapper: A valid mapper.
        /// - returns: Some `URLSessionCompletionReceivable`.
        func chain(_ mapper: @escaping (Error) -> Result<Success, Error>) -> URLSessionCompletionRequester.Response<Success> {
            chain { (result: Result<Success, Error>) in result.flatMapError(mapper) }
        }
    }
}

public extension URLSessionCompletionRequester.Response {
    /// A `class` defining a data task handler.
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
