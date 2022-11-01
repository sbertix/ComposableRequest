//
//  EndpointComponent.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `protocol` defining an instance
/// holding reference to some property
/// of the endpoint request.
public protocol EndpointComponent {
    /// The associated wrapped value type.
    associatedtype Value
    
    /// The component key.
    static var key: EndpointComponentKey { get }
    
    /// The underlying value.
    var value: Value { get }
    
    /// Update the component based on the
    /// parent same component's value.
    /// Defaults to no changes.
    ///
    /// - parameter parent: Any `EndpointComponent`.
    mutating func inherit(from parent: any EndpointComponent)
}

public extension EndpointComponent {
    /// Update the component based on the
    /// parent same component's value.
    /// Defaults to no changes.
    ///
    /// - parameter parent: Any `EndpointComponent`.
    mutating func inherit(from parent: any EndpointComponent) { }
}
