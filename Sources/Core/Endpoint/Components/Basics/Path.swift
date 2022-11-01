//
//  Path.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the last path
/// component for a given endpoint.
public struct Path: EndpointComponent {
    @_spi(ComposableRequest) public static let key: EndpointComponentKey = .path
    @_spi(ComposableRequest) public var value: String
    
    /// Init.
    ///
    /// - parameter path: The last path component for a given endpoint.
    public init(_ path: String) {
        self.value = path
    }
    
    /// Update the component based on the
    /// parent same component's value.
    ///
    /// - parameter parent: Any `EndpointComponent`.
    @_spi(ComposableRequest) public mutating func inherit(from parent: any EndpointComponent) {
        guard let parent = parent as? Self else { return }
        value = "\(parent.value)/\(value)"
    }
}
