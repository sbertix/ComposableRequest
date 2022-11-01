//
//  EndpointProtocol.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `protocol` defining an endpoint key and components.
public protocol EndpointProtocol {
    /// The unique endpoint identifier hash value for the related request.
    /// Successive endpoints with the same `key` will replace this one.
    var key: Int { get }
    
    /// Obtain the `EndpointComponents` from a type-erased input.
    ///
    /// - parameter input: Some `Any`.
    /// - returns: Some `EndpointComponents`.
    func components(from input: Any) -> EndpointComponents
}
