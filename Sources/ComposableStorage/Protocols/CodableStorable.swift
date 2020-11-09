//
//  CodableStorable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/12/20.
//

import Foundation

/// A default `extension` for `Codable` items.
public extension Storable where Self: Codable {
    /// A way to encode the `Data`.
    ///
    /// - parameter storable: A valid instance of `Self`.
    /// - returns: Some `Data`.
    /// - throws: Some `Error`.
    static func encoding(_ storable: Self) throws -> Data {
        try JSONEncoder().encode(storable)
    }

    /// A way to decode some `Data`.
    ///
    /// - parameter data: Some `Data`.
    /// - returns: A valid instance of `Self`.
    /// - throws: Some `Error`.
    static func decoding(_ data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}
