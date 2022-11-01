//
//  Body.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the request body for a given endpoint.
/// Defaults to `nil`.
///
/// - note: Children do not inherit values from their parents if they're non-`nil`.
public struct Body: EndpointComponent {
    @_spi(ComposableRequest) public static let key: EndpointComponentKey = .body
    @_spi(ComposableRequest) public var value: Data?
    
    /// Init.
    ///
    /// - parameter body: The request body for a given endpoint.
    public init(_ body: Data?) {
        self.value = body
    }
    
    /// Init.
    ///
    /// - parameters:
    ///     - body: Some `Encodable` instance.
    ///     - encoder: A valid `JSONEncoder`.
    public init<E: Encodable>(_ body: E, encoder: JSONEncoder) {
        self.init(try? encoder.encode(body))
    }
    
    /// Init.
    ///
    /// A dictionary like `["key1": "value1", "key2": "value2"]`
    /// converts into the data representation of a `String` like
    /// `key1=value1&key2=value2`.
    ///
    /// - parameter body: The request body parameters for a given endpoint.
    public init(parameters body: [String: String]) {
        self.init(body.encoded)
    }
}
