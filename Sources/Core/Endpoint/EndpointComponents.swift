//
//  EndpointComponents.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` holding reference to the content
/// of the URL request of a specific endpoint.
///
/// - note: Use `EndpointBuilder` to init.
public struct EndpointComponents {
    /// The collection of all available components.
    var components: [EndpointComponentKey: any EndpointComponent]
    
    /// Init.
    init() {
        self.components = [:]
    }
    
    /// Init.
    ///
    /// - parameter component: An `EndpointComponent`.
    init<E: EndpointComponent>(_ component: E) {
        self.components = [E.key: component]
    }
    
    /// Update existing components.
    ///
    /// - parameter component: An `EndpointComponent`.
    mutating func update<E: EndpointComponent>(_ component: E) {
        components[E.key] = component
    }
    
    /// Update existing components.
    ///
    /// - parameter component: Some `EndpointComponents`.
    mutating func update(_ components: EndpointComponents) {
        self.components.merge(components.components) { $1 }
    }
    
    /// Update existing components based on inherited values.
    ///
    /// - parameter parent: Some `EndpointComponents`.
    mutating func inherit(from parent: EndpointComponents) {
        for key in Set(components.keys).union(parent.components.keys) {
            switch (components[key], parent.components[key]) {
            case (nil, let rhs?):
                // If there's no cached value and
                // a parent one is set, always
                // upadte it.
                components[key] = rhs
            case (var lhs?, let rhs?):
                // If there's already a value and
                // a parent one is set, deal with
                // inheritance rules.
                lhs.inherit(from: rhs)
                components[key] = lhs
            default:
                // Otherrwise do nothing.
                break
            }
        }
    }
}
