//
//  SessionProviderType.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `protocol` defining a specific provider.
public protocol SessionProviderType: Provider where Input == SessionProviderInput { }

public extension SessionProviderType {
    /// Update the session.
    ///
    /// - parameter input: A valid `Input`.
    /// - returns: Some `Content`.
    func session(_ input: Input) -> Output {
        Self.generate(self, from: input)
    }

    /// Update the session.
    ///
    /// - parameters:
    ///     - session: A valid `URLSession`.
    ///     - retries: A valid `Int`. Defaults to `0`.
    ///     - logger: An optional `Logger`. Defaults to `nil`, meaning `Logger.default` will be used instead.
    /// - returns: Some `Content`.
    func session(_ session: URLSession,
                 retries: Int = 0,
                 logging logger: Logger.Level? = nil) -> Output {
        self.session(.init(session: session,
                           retries: retries,
                           logger: logger))
    }
}
