//
//  URLSessionAsyncRequester+Output.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/08/21.
//

#if swift(>=5.5)
import Foundation

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public extension URLSessionAsyncRequester {
    /// A `struct` defining the output for a `URLSessionAsyncRequester`.
    struct Response<Success>: URLSessionAsyncReceivable {
        /// The task priority.
        public let taskPriority: TaskPriority?
        /// The underlying task.
        public let task: Task<Success, Error>

        /// The underlying response.
        public var response: URLSessionAsyncRequester.Response<Success> {
            self
        }

        /// Init.
        ///
        /// - parameters:
        ///     - priority: An optional `TaskPriority`.
        ///     - operation: An async operation.
        /// - note: This cannot be constructed directly.
        public init(priority: TaskPriority?, operation: @Sendable @escaping () async throws -> Success) {
            self.taskPriority = priority
            self.task = .init(priority: priority, operation: operation)
        }

        /// Flat map the current task.
        ///
        /// - parameter mapper: A valid mapper.
        /// - returns: Some `URLSessionAsyncReceivable`.
        func chain<S>(_ mapper: @escaping (Result<Success, Error>) async -> Result<S, Error>) -> URLSessionAsyncRequester.Response<S> {
            .init(priority: taskPriority) { try await mapper(task.result).get() }
        }

        /// Flat map the current task.
        ///
        /// - parameter mapper: A valid mapper.
        /// - returns: Some `URLSessionAsyncReceivable`.
        func chain<S>(_ mapper: @escaping (Success) async -> Result<S, Error>) -> URLSessionAsyncRequester.Response<S> {
            chain { (result: Result<Success, Error>) in
                switch result {
                case .success(let success):
                    return await mapper(success)
                case .failure(let failure):
                    return .failure(failure)
                }
            }
        }

        /// Flat map the current task.
        ///
        /// - parameter mapper: A valid mapper.
        /// - returns: Some `URLSessionAsyncReceivable`.
        func chain(_ mapper: @escaping (Error) async -> Result<Success, Error>) -> URLSessionAsyncRequester.Response<Success> {
            chain { (result: Result<Success, Error>) in
                switch result {
                case .success(let success):
                    return .success(success)
                case .failure(let failure):
                    return await mapper(failure)
                }
            }
        }
    }
}
#endif
