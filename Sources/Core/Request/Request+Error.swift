//
//  Request+Error.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 18/08/21.
//

import Foundation

public extension Request {
    /// An `enum` listing error values.
    enum Error: Swift.Error {
        /// Invalid request.
        case invalidRequest(Request)
        /// Cancelled request.
        case cancelled
    }
}
