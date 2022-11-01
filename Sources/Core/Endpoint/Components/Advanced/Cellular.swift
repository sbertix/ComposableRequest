//
//  Cellular.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining whether the request
/// for a given endpoint can run on cellular or not.
/// Defaults to `true`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Cellular: EndpointComponent {
    @_spi(ComposableRequest) public static let key: EndpointComponentKey = .cellular
    @_spi(ComposableRequest) public let value: Bool
    
    /// Init.
    ///
    /// - parameter allowsCellularAccess: A `Bool` representing whether it can run on cellular or not.
    public init(_ allowsCellularAccess: Bool) {
        self.value = allowsCellularAccess
    }
}
