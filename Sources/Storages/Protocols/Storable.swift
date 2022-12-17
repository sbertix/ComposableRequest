//
//  Storable.swift
//  Storages
//
//  Created by Stefano Bertagno on 19/04/2020.
//

import Foundation

/// A `protocol` defining an instance capable of being turned into
/// some `Data`, while being identified by some `Label`.
public protocol Storable: Identifiable where ID == String {
    /// Init an instance decoding some `Data`.
    ///
    /// - parameter data: Some `Data`.
    /// - throws: Any `Error`.
    init(decoding data: Data) throws

    /// Encode the instance into some `Data`.
    ///
    /// - throws: Any `Error`.
    /// - returns: Some `Data`.
    func encoded() throws -> Data
}

public extension Storable where Self: Decodable {
    /// Init an instance decoding some `Data`.
    ///
    /// - parameter data: Some `Data`.
    /// - throws: Any `Error`.
    init(decoding data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

public extension Storable where Self: Encodable {
    /// Encode the instance into some `Data`.
    ///
    /// - throws: Any `Error`.
    /// - returns: Some `Data`.
    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
