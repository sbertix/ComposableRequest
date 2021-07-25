//
//  Request+Response.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/02/21.
//

import Foundation

public extension Request {
    /// A `struct` defining the associated response type.
    struct Response {
        /// Some optional `Data`.
        public let data: Data
        /// An optional `URLResponse`.
        public let response: URLResponse
    }
}
