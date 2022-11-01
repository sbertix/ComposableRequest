//
//  Method.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// A `protocol` describing an instance providing the method of a `URLRequest`.
public protocol ProtocolMethod {
    /// The underlying request method.
    var method: HTTPMethod { get }

    /// Copy `self` and replace its `method`.
    ///
    /// - parameter mody: A valid `HTTPMethod`.
    /// - returns: A valid `Self`.
    func method(_ method: HTTPMethod) -> Self
}
