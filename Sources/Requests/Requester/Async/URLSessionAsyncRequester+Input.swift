//
//  URLSessionAsyncRequester+Input.swift
//  File
//
//  Created by Stefano Bertagno on 20/08/21.
//

#if swift(>=5.5)
import Foundation

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public extension URLSessionAsyncRequester {
    /// A `struct` defining a valid requester input.
    struct Input: RequesterInput {
        /// The session instance.
        public let session: URLSession
        /// The task priority.
        public let priority: TaskPriority?
        /// The optional logger.
        public let logger: Logger?

        /// Init.
        ///
        /// - parameters:
        ///     - session: A valid `URLSession`.
        ///     - priority: An optional `TaskPriority`.
        ///     - logger: An optional `Logger`. Defaults to `.default`, meaning the default `Logger` will be used instead.
        /// - note:
        ///     We suggest custom implementation of `ComposableRequest` to implement
        ///     a custom `init` defaulting to their custom (or not) `URLSession`, and even
        ///     a static shared `default` instance.
        public init(session: URLSession,
                    priority: TaskPriority?,
                    logger: Logger? = .default) {
            self.session = session
            self.priority = priority
            self.logger = logger
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
            self.init(session: session, priority: nil, logger: logger)
        }
    }
}
#endif
