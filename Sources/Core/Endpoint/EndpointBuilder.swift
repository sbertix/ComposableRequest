//
//  EndpointBuilder.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

@resultBuilder
public struct EndpointBuilder {
    /// Combine a collection of `EndpointComponents` together.
    ///
    /// - parameter components: A variadic collection of `EndpointComponents`.
    /// - returns: Some `EndpointComponents`.
    public static func buildBlock(_ components: EndpointComponents...) -> EndpointComponents {
        buildArray(components)
    }
    
    /// Build some optional `EndpointComponents`.
    ///
    /// - parameter component: Some optional `EndpointComponents`.
    /// - returns: Some `EndpointComponents`.
    public static func buildOptional(_ component: EndpointComponents?) -> EndpointComponents {
        component ?? .init()
    }
    
    /// Build the first `EndpointComponents`.
    ///
    /// - parameter component: Some `EndpointComponents`.
    /// - returns: Some `EndpointComponents`.
    public static func buildEither(first component: EndpointComponents) -> EndpointComponents {
        component
    }
    
    /// Build the second `EndpointComponents`.
    ///
    /// - parameter component: Some `EndpointComponents`.
    /// - returns: Some `EndpointComponents`.
    public static func buildEither(second component: EndpointComponents) -> EndpointComponents {
        component
    }
    
    /// Build an array of `EndpointComponents`.
    ///
    /// - parameter component: An `EndpointComponent` array.
    /// - returns: Some `EndpointComponents`.
    public static func buildArray(_ components: [EndpointComponents]) -> EndpointComponents {
        components.reduce(into: EndpointComponents()) { $0.update($1) }
    }
    
    /// Build some `EndpointComponents` constrained by limited availability.
    ///
    /// - parameter component: An `EndpointComponent`.
    /// - returns: Some `EndpointComponents`.
    public static func buildLimitedAvailability(_ component: EndpointComponents) -> EndpointComponents {
        component
    }
    
    /// Build an `EndpointComponent`.
    ///
    /// - parameter expression: A concrete instance of `EndpointComponent`.
    /// - returns: Some `EndpointComponents`.
    public static func buildExpression(_ expression: some EndpointComponent) -> EndpointComponents {
        .init(expression)
    }
}
