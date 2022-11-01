//
//  Constrained.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining whether the request
/// for a given endpoint should run on a constrained
/// network.
/// Defaults to `true`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Constrained: EndpointComponent {
    @_spi(ComposableRequest) public static let key: EndpointComponentKey = .constrained
    @_spi(ComposableRequest) public let value: Bool
    
    /// Init.
    ///
    /// - parameter allowsconstrained: A `Bool` representing whether it can run on constrained networks or not.
    public init(_ allowsconstrained: Bool) {
        self.value = allowsconstrained
    }
}
