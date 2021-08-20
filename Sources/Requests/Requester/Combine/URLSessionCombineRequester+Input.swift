//
//  URLSessionCombineRequester+Input.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

#if canImport(Combine)
import Foundation

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public extension URLSessionCombineRequester {
    /// A `struct` defining a valid requester input.
    struct Input: RequesterInput {
        /// The session instance.
        public let session: URLSession
        /// The retries count.
        public let retries: Int
        /// The optional logger.
        public let logger: Logger?

        /// Init.
        ///
        /// - parameters:
        ///     - session: A valid `URLSession`.
        ///     - retries: A valid `Int`.
        ///     - logger: An optional `Logger`. Defaults to `.default`, meaning the default `Logger` will be used instead.
        /// - note:
        ///     We suggest custom implementation of `ComposableRequest` to implement
        ///     a custom `init` defaulting to their custom (or not) `URLSession`, and even
        ///     a static shared `default` instance.
        public init(session: URLSession,
                    retries: Int,
                    logger: Logger? = .default) {
            self.session = session
            self.retries = retries
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
        public init(session: URLSession, logger: Logger? = .default) {
            self.init(session: session, retries: 0, logger: nil)
        }
    }
}
#endif
