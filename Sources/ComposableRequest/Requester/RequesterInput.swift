//
//  RequesterInput.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

/// A `protocol` defining the input for a `Requester`.
public protocol RequesterInput {
    /// A valid session.
    var session: URLSession { get }
    /// An optional logger.
    var logger: Logger? { get }

    /// Init.
    ///
    /// - parameters:
    ///     - session: A valid `URLSession`.
    ///     - logger: An optional `Logger`.
    init(session: URLSession, logger: Logger?)
}
