//
//  Query.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the query
/// items for a given endpoint.
/// Defaults to empty.
public struct Query: EndpointComponent {
    @_spi(ComposableRequest) public static let key: EndpointComponentKey = .query
    @_spi(ComposableRequest) public var value: [String: String?]
    
    /// Init.
    ///
    /// - parameter query: The query items for a given endpoint.
    /// - note: `nil`-valued items will still be added to the query to allow for flags, switches, etc.
    public init(withFlags query: [String: String?]) {
        self.value = query
    }

    /// Init.
    ///
    /// - parameter query: The query items for a given endpoint.
    /// - note: `nil`-valued items will be discarded.
    public init(_ query: [String: String?]) {
        self.init(withFlags: query.compactMapValues { $0 })
    }

    /// Init.
    ///
    /// - parameter query: The query items for a given endpoint.
    public init(_ query: [String: String]) {
        self.init(withFlags: query)
    }
        
    /// Init.
    ///
    /// - parameters:
    ///     - value: A `String` representing a single query item value.
    ///     - key: A `String` representing a single query item key.
    public init(_ value: String, forKey key: String) {
        self.init(withFlags: [key: value])
    }
    
    /// Init.
    ///
    /// - parameters:
    ///     - value: An optional `String` representing a single query item value. `nil` will be ignored.
    ///     - key: A `String` representing a single query item key.
    public init(_ value: String?, forKey key: String) {
        self.init(withFlags: value.flatMap { [key: $0] } ?? [:])
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
