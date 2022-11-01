//
//  NetworkServiceType.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the request network
/// service type for a specific endpoint.
/// /// Defaults to `.default`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Service: EndpointComponent {
    @_spi(ComposableRequest) public static let key: EndpointComponentKey = .service
    @_spi(ComposableRequest) public let value: URLRequest.NetworkServiceType
    
    /// Init.
    ///
    /// - parameter networkServiceType: A `URLRequest.NetworkServiceType`.
    public init(_ networkServiceType: URLRequest.NetworkServiceType) {
        self.value = networkServiceType
    }
}
