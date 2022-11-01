//
//  Headers.swift
//  
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the request
/// headers for a given endpoint.
/// Defaults to empty.
public struct Headers: EndpointComponent {
    @_spi(ComposableRequest) public static let key: EndpointComponentKey = .headers
    @_spi(ComposableRequest) public var value: [String: String]
    
    /// Init.
    ///
    /// - parameter headers: The request headers for a given endpoint.
    public init(_ headers: [String: String]) {
        self.value = headers
    }
    
    /// Init.
    ///
    /// - parameter headers: The request headers for a given endpoint.
    public init(_ headers: [String: String?]) {
        self.init(headers.compactMapValues { $0 })
    }
    
    /// Init.
    ///
    /// - parameters:
    ///     - value: A `String` representing a single request header value.
    ///     - key: A `String` representing a single request header key.
    public init(_ value: String, forKey key: String) {
        self.init([key: value])
    }
    
    /// Init.
    ///
    /// - parameters:
    ///     - value: An optional `String` representing a single request header value. `nil` will be ignored.
    ///     - key: A `String` representing a single request header key.
    public init(_ value: String?, forKey key: String) {
        self.init(value.flatMap { [key: $0] } ?? [:])
    }
        
    /// Init.
    ///
    /// - parameters uniqueKeysAndValues: A sequence of unique `String` tuples of request header keys and values.
    public init<C: Sequence>(_ keysAndValues: C) where C.Element == (String, String) {
        self.init(.init(uniqueKeysWithValues: keysAndValues))
    }
    
    /// Init.
    ///
    /// - parameters:
    ///     - keys: A sequence of unique `String`s representing request header keys.
    ///     - values: A sequence of `String`s representing request header values.
    public init<K: Sequence, V: Sequence>(keys: K, values: V) where K.Element == String, V.Element == String {
        self.init(zip(keys, values))
    }
    
    
    /// Update the component based on the
    /// parent same component's value.
    ///
    /// - parameter parent: Any `EndpointComponent`.
    @_spi(ComposableRequest) public mutating func inherit(from parent: any EndpointComponent) {
        guard let parent = parent as? Self else { return }
        value.merge(parent.value) { child, _ in child }
    }
}
