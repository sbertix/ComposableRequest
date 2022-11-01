//
//  constrained.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining whether the request
/// for a given endpoint is considered expensive.
/// Defaults to `true`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Expensive: EndpointComponent {
    @_spi(ComposableRequest) public static let key: EndpointComponentKey = .expensive
    @_spi(ComposableRequest) public let value: Bool
    
    /// Init.
    ///
    /// - parameter allowsExpensiveNetworkAccess: A `Bool` representing whether it's expensive to run.
    public init(_ allowsExpensiveNetworkAccess: Bool) {
        self.value = allowsExpensiveNetworkAccess
    }
}
