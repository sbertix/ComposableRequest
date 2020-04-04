//
//  AnySecret.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/04/2020.
//

import Foundation

/// A `struct` holding reference to a type-erased `Secret`.
public struct AnySecret: Secret {
    /// The request header fields.
    public var headerFields: [String: String]
    /// The request body parameters.
    public var body: [String: String]

    /// Init.
    /// - parameters:
    ///     - headerFields: A `Dictionary` of `String`s representing the request header fields.
    ///     - body: An optional `Requester.Body`.
    public init(headerFields: [String: String], body: [String: String]) {
        self.headerFields = headerFields
        self.body = body
    }

    /// Init.
    /// - parameter secret: A concrete-typed `Secret`.
    public init(_ secret: Secret) {
        self.init(headerFields: secret.headerFields, body: secret.body)
    }
}
