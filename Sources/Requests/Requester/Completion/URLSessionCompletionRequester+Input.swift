//
//  URLSessionCompletionRequester+Input.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

public extension URLSessionCompletionRequester {
    /// A `struct` defining a valid requester input.
    struct Input: RequesterInput {
        /// The session instance.
        public let session: URLSession
        /// The optional logger.
        public let logger: Logger?

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
            self.session = session
            self.logger = logger
        }
    }
}
