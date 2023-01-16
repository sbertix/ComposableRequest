//
//  Method.swift
//  Requests
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// An `enum` listing all `URLRequest` allowed `httpMethod`s.
/// Defaults to `.default`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public enum HTTPMethod: String, Hashable {
    /// `GET` when no `body` is set, `POST` otherwise.
    case `default` = ""
    /// `GET`.
    case get = "GET"
    /// `HEADER`.
    case header = "HEADER"
    /// `POST`.
    case post = "POST"
    /// `PUT`.
    case put = "PUT"
    /// `DELETE`.
    case delete = "DELETE"
    /// `CONNECT`.
    case connect = "CONNECT"
    /// `OPTIONS`.
    case options = "OPTIONS"
    /// `TRACE`.
    case trace = "TRACE"
    /// `PATCH`.
    case patch = "PATCH"
}

/// A `struct` defining the request
/// HTTP method for a given endpoint.
public struct Method: Component {
    /// The default value when no cached
    /// component can be found.
    public static var defaultValue: Method {
        .init(.default)
    }

    /// The request HTTP method for a given endpoint.
    public let value: HTTPMethod

    /// Init.
    ///
    /// - parameter method: The request HTTP method for a given endpoint.
    public init(_ method: HTTPMethod) {
        self.value = method
    }

    /// Update a given `URLRequest`.
    ///
    /// - parameter request: A mutable `URLRequest`.
    public func update(_ request: inout URLRequest) {
        // `Method` is guaranteed to run after
        // `Body` in code, so we can just read
        // the stored value.
        request.httpMethod = value == .default
            ? (request.httpBody != nil ? "POST" : "GET")
            : value.rawValue
    }
}
