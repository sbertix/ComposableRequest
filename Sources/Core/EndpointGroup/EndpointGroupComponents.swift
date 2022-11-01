//
//  EndpointGroupComponents.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` holding reference to the
/// content of a specific endpoint group.
///
/// - note: Use `EndpointGroupBuilder` to init.
public struct EndpointGroupComponents {
    /// The collection of all global components.
    var components: EndpointComponents
    /// The collection of all available endpoints.
    var endpoints: [Int: any EndpointProtocol]
    
    /// Init.
    init() {
        self.components = .init()
        self.endpoints = [:]
    }
    
    /// Init.
    ///
    /// - parameter endpoint: An `EndpointProtocol`.
    init<E: EndpointProtocol>(_ endpoint: E) {
        self.components = .init()
        self.endpoints = [endpoint.key: endpoint]
    }
    
    /// Init.
    ///
    /// - parameter component: An `EndpointComponent`.
    init<E: EndpointComponent>(_ component: E) {
        self.components = .init(component)
        self.endpoints = [:]
    }
    
    /// Init.
    ///
    /// - parameter group: An `EndpointGroup`.
    init(_ group: EndpointGroup) {
        if group.block.components.components.isEmpty {
            // If there are no global components,
            // you can just deal with endpoints
            // directly.
            self.components = .init()
            self.endpoints = group.block.endpoints
        } else {
            // Otherwise we need to modify them.
            self.components = .init()
            self.endpoints = group.block.endpoints.reduce(into: [:]) {
                $0[$1.key] = EndpointModifier(endpoint: $1.value, components: group.block.components)
            }
        }
    }
    
    /// Update existing endpoints.
    ///
    /// - parameter endpoint: Some `EndpointProtocol`.
    mutating func update<E: EndpointProtocol>(_ endpoint: E) {
        endpoints[endpoint.key.hashValue] = endpoint
    }
    
    /// Update existing endpoints.
    ///
    /// - parameter endpoints: Some `EndpointGroupComponents`.
    mutating func update(_ components: EndpointGroupComponents) {
        self.components.update(components.components)
        self.endpoints.merge(components.endpoints) { $1 }
    }
}
