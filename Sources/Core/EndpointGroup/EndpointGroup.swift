//
//  EndpointGroup.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` a reference to
/// some endpoint API requests.
public struct EndpointGroup {
    /// Endpoint definitions.
    let block: EndpointGroupComponents
    
    /// Init.
    ///
    /// - parameter endpoints: A factory for all available endpoints.
    public init(@EndpointGroupBuilder endpoints: () -> EndpointGroupComponents) {
        self.block = endpoints()
    }
    
    /// Obtain the `EndpointComponents` for a given key.
    ///
    /// - parameters:
    ///     - key: A concrete instance of `EndpointKey`.
    ///     - input: A valid input.
    /// - returns: Some `EndpointComponents`.
    public func components<K: EndpointKey>(for key: K, with input: K.Input) -> EndpointComponents! {
        var components = block.endpoints[key.endpointID.hashValue]?.components(from: input)
        components?.inherit(from: block.components)
        return components
    }
    
    /// Obtain the `EndpointComponents` for a given key.
    ///
    /// - parameter key: A concrete instance of `EndpointKey`.
    /// - returns: Some `EndpointComponents`.
    public func components<K: EndpointKey>(for key: K) -> EndpointComponents! where K.Input == Void {
        var components = block.endpoints[key.endpointID.hashValue]?.components(from: ())
        components?.inherit(from: block.components)
        return components ?? block.components
    }
}
