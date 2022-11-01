//
//  Method.swift
//  Core
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
public struct Method: EndpointComponent {
    @_spi(ComposableRequest) public static let key: EndpointComponentKey = .method
    @_spi(ComposableRequest) public var value: HTTPMethod
    
    /// Init.
    ///
    /// - parameter method: The request HTTP method for a given endpoint.
    public init(_ method: HTTPMethod) {
        self.value = method
    }
}
