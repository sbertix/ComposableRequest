//
//  SessionProviderInput.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `struct` defining a `SessionProviderInput`.
public struct SessionProviderInput {
    /// The request session.
    public let session: URLSession
    /// The number of retries before outputting an exception.
    public let retries: Int
    /// An optional logger level.
    public let logger: Logger.Level?

    /// Init.
    ///
    /// - parameters:
    ///     - session: A valid `URLSession`.
    ///     - retries: A valid `Int`.
    ///     - logger: An optional `Logger`.
    public init(session: URLSession,
                retries: Int,
                logger: Logger.Level?) {
        self.session = session
        self.retries = retries
        self.logger = logger
    }
}
