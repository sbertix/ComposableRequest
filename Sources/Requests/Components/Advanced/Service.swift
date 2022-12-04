//
//  NetworkServiceType.swift
//  Requests
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the request network
/// service type for a specific endpoint.
/// /// Defaults to `.default`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Service: Component {
    /// The default value when no cached
    /// component can be found.
    public static var defaultValue: Service {
        .init(.default)
    }

    /// The request network service type.
    public let value: URLRequest.NetworkServiceType

    /// Init.
    ///
    /// - parameter networkServiceType: A `URLRequest.NetworkServiceType`.
    public init(_ networkServiceType: URLRequest.NetworkServiceType) {
        self.value = networkServiceType
    }

    /// Update a given `URLRequest`.
    ///
    /// - parameter request: A mutable `URLRequest`.
    public func update(_ request: inout URLRequest) {
        request.networkServiceType = value
    }
}
