//
//  Endpoint.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the entire reference
/// to an endpoint API request.
public struct Endpoint: EndpointProtocol {
    /// The unique endpoint identifier value for the related request.
    /// Successive endpoints with the same `key` will replace this one.
    @_spi(ComposableRequest) public let key: Int

    /// The content of the request.
    var block: (Any) -> EndpointComponents
    
    /// Init.
    ///
    /// - parameters:
    ///     - key: The unique key for the related request.
    ///     - components: A factory for the actual content request.
    /// - note: Successive endpoints with the same `key` will replace this one.
    public init<K: EndpointKey>(_ key: K, @EndpointBuilder components: @escaping (K.Input) -> EndpointComponents) {
        self.key = key.endpointID.hashValue
        // We can only ever access `block` from
        // it's related `EndpointKey`, so this
        // *should* be fine.
        self.block = { components($0 as! K.Input) }
    }
    
    /// Obtain the `EndpointComponents` from a type-erased input.
    ///
    /// - parameter input: Some `Any`.
    /// - returns: Some `EndpointComponents`.
    @_spi(ComposableRequest) public func components(from input: Any) -> EndpointComponents {
        block(input)
    }
}
