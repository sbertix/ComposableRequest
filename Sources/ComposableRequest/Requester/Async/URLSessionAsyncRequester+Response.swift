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
        /// The underlying task.
        public let task: Task<Success, Error>

        /// Init.
        ///
        /// - parameter task: A valid `Task`.
        /// - note: This cannot be constructed directly.
        init(task: Task<Success, Error>) {
            self.task = task
        }

        /// Init.
        ///
        /// - parameters:
        ///     - priority: An optional `TaskPriority`.
        ///     - operation: An async operation.
        /// - note: This cannot be constructed directly.
        init(priority: TaskPriority?, operation: @Sendable @escaping () async throws -> Success) {
            self.init(task: .init(priority: priority, operation: operation))
        }
    }
}
#endif
