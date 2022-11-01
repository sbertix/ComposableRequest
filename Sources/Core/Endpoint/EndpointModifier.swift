//
//  EndpointModifier.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining an instance capable of updating
/// some `EndpointComponents` at runtime.
public struct EndpointModifier: EndpointProtocol {
    /// The unique endpoint identifier hash value for the related request.
    /// Successive endpoints with the same `key` will replace this one.
    @_spi(ComposableRequest) public var key: Int { endpoint.key }

    /// The original endpoint.
    let endpoint: any EndpointProtocol
    /// The endpoint components to be inherited by the original endpoint.
    var components: EndpointComponents
        
    /// Obtain the `EndpointComponents` from a type-erased input.
    ///
    /// - parameter input: Some `Any`.
    /// - returns: Some `EndpointComponents`.
    @_spi(ComposableRequest) public func components(from input: Any) -> EndpointComponents {
        var components = endpoint.components(from: input)
        components.inherit(from: self.components)
        return components
    }
}
