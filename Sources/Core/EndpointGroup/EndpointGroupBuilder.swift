//
//  EndpointGroupBuilder.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

@resultBuilder
public struct EndpointGroupBuilder {
    /// Combine a collection of `EndpointGroupComponents` together.
    ///
    /// - parameter components: A variadic collection of `EndpointGroupComponents`.
    /// - returns: Some `EndpointGroupComponents`.
    public static func buildBlock(_ components: EndpointGroupComponents...) -> EndpointGroupComponents {
        buildArray(components)
    }
    
    /// Build an optional `EndpointGroupComponents`.
    ///
    /// - parameter component: An optional `EndpointGroupComponents`.
    /// - returns: Some `EndpointGroupComponents`.
    public static func buildOptional(_ component: EndpointGroupComponents?) -> EndpointGroupComponents {
        component ?? .init()
    }
    
    /// Build the first `EndpointGroupComponents`.
    ///
    /// - parameter component: An optional `EndpointGroupComponents`.
    /// - returns: Some `EndpointGroupComponents`.
    public static func buildEither(first component: EndpointGroupComponents) -> EndpointGroupComponents {
        component
    }
    
    /// Build the second `EndpointGroupComponents`.
    ///
    /// - parameter component: An optional `EndpointGroupComponents`.
    /// - returns: Some `EndpointGroupComponents`.
    public static func buildEither(second component: EndpointGroupComponents) -> EndpointGroupComponents {
        component
    }
    
    /// Build an array of `EndpointGroupComponents`s.
    ///
    /// - parameter component: An `EndpointGroupComponents` array.
    /// - returns: Some `EndpointGroupComponents`.
    public static func buildArray(_ components: [EndpointGroupComponents]) -> EndpointGroupComponents {
        components.reduce(into: EndpointGroupComponents()) { $0.update($1) }
    }
    
    /// Build some `EndpointGroupComponents` constrained by limited availability.
    ///
    /// - parameter component: An `EndpointGroupComponents`.
    /// - returns: Some `EndpointGroupComponents`.
    public static func buildLimitedAvailability(_ component: EndpointGroupComponents) -> EndpointGroupComponents {
        component
    }
    
    /// Build an `EndpointProtocol`.
    ///
    /// - parameter expression: A concrete instance of `EndpointProtocol`.
    /// - returns: Some `EndpointGroupComponents`.
    public static func buildExpression(_ expression: some EndpointProtocol) -> EndpointGroupComponents {
        .init(expression)
    }
    
    /// Build an `EndpointComponent`.
    ///
    /// - parameter expression: A concrete instance of `EndpointComponent`.
    /// - returns: Some `EndpointGroupComponents`.
    public static func buildExpression(_ expression: some EndpointComponent) -> EndpointGroupComponents {
        .init(expression)
    }
    
    /// Build an `EndpointGroup`.
    ///
    /// - parameter expression: An `EndpointGroup`.
    /// - returns: Some `EndpointGroupComponents`.
    public static func buildExpression(_ expression: EndpointGroup) -> EndpointGroupComponents {
        .init(expression)
    }
}
