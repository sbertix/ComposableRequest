//
//  RequestMethod.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

public extension Request {
    /// An `enum` representing a `URLRequest` allowed `httpMethod`s.
    enum Method: String, Hashable {
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
}
