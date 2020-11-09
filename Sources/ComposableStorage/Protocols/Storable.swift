//
//  Storable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/04/2020.
//

import Foundation

/// A `protocol` defining an instance capable of being turned into
/// some `Data`, while being identified by some `String`.
public protocol Storable {
    /// The underlying identfiier.
    var label: String { get }

    /// A way to encode the `Data`.
    ///
    /// - parameter storable: A valid instance of `Self`.
    /// - returns: Some `Data`.
    /// - throws: Some `Error`.
    static func encoding(_ storable: Self) throws -> Data

    /// A way to decode some `Data`.
    ///
    /// - parameter data: Some `Data`.
    /// - returns: A valid instance of `Self`.
    /// - throws: Some `Error`.
    static func decoding(_ data: Data) throws -> Self
}

public extension Storable {
    /// Cache `self` in a valid `Storage`.
    ///
    /// - parameter storage: A valid `NonThrowingStorage`.
    /// - returns: `self`.
    @discardableResult
    func store<S: NonThrowingStorage>(in storage: S) -> Self where S.Item == Self {
        storage.store(self)
    }

    /// Cache `self` in a valid `Storage`.
    ///
    /// - parameter storage: A valid `ThrowingStorage`.
    /// - returns: `self`.
    @discardableResult
    func store<S: ThrowingStorage>(in storage: S) throws -> Self where S.Item == Self {
        try storage.store(self)
    }

    /// Return the first `Self` matching `label` in `storage`, `nil` if none was found.
    ///
    /// - parameters:
    ///     - label: A valid `String`.
    ///     - storage: A valid `NonThrowingStorage`.
    /// - returns: An optional `Self`.
    static func matching<S: NonThrowingStorage>(_ label: String, in storage: S) -> Self? where S.Item == Self {
        storage.item(matching: label)
    }

    /// Return the first `Self` matching `label` in `storage`, `nil` if none was found.
    ///
    /// - parameters:
    ///     - label: A valid `String`.
    ///     - storage: A valid `ThrowingStorage`.
    /// - returns: An optional `Self`.
    static func matching<S: ThrowingStorage>(_ label: String, in storage: S) throws -> Self? where S.Item == Self {
        try storage.item(matching: label)
    }
}
