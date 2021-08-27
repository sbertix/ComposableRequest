//
//  URLSessionCompletionRequester+Output.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

import Future

public extension URLSessionCompletionRequester {
    /// A `struct` defining the output for a `URLSessionCompletionRequester`.
    struct Response<Success>: URLSessionCompletionReceivable {
        /// The underlying data task.
        public weak var task: URLSessionDataTask?
        /// The underlying future.
        public let future: Future<Success, Error>

        /// The underlying response.
        public var response: URLSessionCompletionRequester.Response<Success> {
            self
        }

        /// Resume the underlying task, if it exists.
        ///
        /// - returns: An optional `URLSessionDataTask`.
        @discardableResult
        public func resume() -> URLSessionDataTask? {
            task?.resume()
            return task
        }

        /// Init.
        ///
        /// - parameters:
        ///     - task: An optional `URLSessionDataTask`. Defaults to `nil`.
        ///     - future: A valid `Future`.
        public init(task: URLSessionDataTask? = nil, future: Future<Success, Error>) {
            self.task = task
            self.future = future
        }

        /// Flat map the current task.
        ///
        /// - parameter mapper: A valid mapper.
        /// - returns: Some `URLSessionCompletionReceivable`.
        func chain<S>(_ mapper: @escaping (Result<Success, Error>) -> Result<S, Error>) -> URLSessionCompletionRequester.Response<S> {
            .init(task: task, future: future.materialize().flatMap { .init(result: mapper($0)) })
        }

        /// Flat map the current task.
        ///
        /// - parameter mapper: A valid mapper.
        /// - returns: Some `URLSessionCompletionReceivable`.
        func chain<S>(_ mapper: @escaping (Success) -> Result<S, Error>) -> URLSessionCompletionRequester.Response<S> {
            .init(task: task, future: future.flatMap { .init(result: mapper($0)) })
        }

        /// Flat map the current task.
        ///
        /// - parameter mapper: A valid mapper.
        /// - returns: Some `URLSessionCompletionReceivable`.
        func chain(_ mapper: @escaping (Error) -> Result<Success, Error>) -> URLSessionCompletionRequester.Response<Success> {
            .init(task: task, future: future.flatMapError { .init(result: mapper($0)) })
        }
    }
}
