//
//  Method.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// An `enum` listing all `URLRequest` allowed `httpMethod`s.
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

/// A `protocol` describing an instance providing the method of a `URLRequest`.
public protocol Method {
    /// The underlying request method.
    var method: HTTPMethod { get }

    /// Copy `self` and replace its `method`.
    ///
    /// - parameter mody: A valid `HTTPMethod`.
    /// - returns: A valid `Self`.
    func method(_ method: HTTPMethod) -> Self
}
