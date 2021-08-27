//
//  ThrowingStorage.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/11/20.
//

import Foundation

/// A `protocol` defining an instance capable of caching `Storable`s.
///
/// - note: If your `Storage` implementation is guaranteed not to throw, conform to `NonThrowingStorage` instead.
public protocol ThrowingStorage: Storage {
    /// Return the first `Item` matching `label`, `nil` if none was found.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    func item(matching label: String) throws -> Item?

    /// Return all stored `Item`s.
    ///
    /// - returns: An order collection of `Item`s.
    /// - throws: Some `Error`.
    func items() throws -> [Item]

    /// Store some `Item`, overwriting the ones matching its `label`.
    ///
    /// - parameter item: A valid `Item`.
    /// - returns: `item`.
    /// - throws: Some `Error`.
    @discardableResult
    func store(_ item: Item) throws -> Item

    /// Return an `Item`, if found, then removes it from storage.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    @discardableResult
    func discard(_ label: String) throws -> Item?

    /// Empty storage.
    ///
    /// - throws: Some `Error`.
    func empty() throws
}

public extension ThrowingStorage {
    /// Return the first `Item` matching `label`, `nil` if none was found.
    ///
    /// - parameters:
    ///     - label: A valid `String`.
    ///     - storage: A valid `Storage`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    static func item(matching label: String, in storage: Self) throws -> Item? {
        try storage.item(matching: label)
    }

    /// Return all stored `Item`s.
    ///
    /// - parameter storage: A valid `Storage`.
    /// - returns: An order collection of `Item`s.
    /// - throws: Some `Error`.
    static func items(in storage: Self) throws -> [Item] {
        try storage.items()
    }

    /// Store some `Item`, overwriting the ones matching its `label`.
    ///
    /// - parameters:
    ///     - item: A valid `Item`.
    ///     - storage: A valid `Storage`.
    /// - returns: `item`.
    /// - throws: Some `Error`.
    @discardableResult
    static func store(_ item: Item, in storage: Self) throws -> Item {
        try storage.store(item)
    }

    /// Return an `Item`, if found, then removes it from storage.
    ///
    /// - parameters:
    ///     - label: A valid `String`.
    ///     - storage: A valid `Storage`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    @discardableResult
    static func discard(_ label: String, in storage: Self) throws -> Item? {
        try storage.discard(label)
    }

    /// Empty storage.
    ///
    /// - parameter storage: A valid `Storage`.
    /// - throws: Some `Error`.
    static func empty(_ storage: Self) throws {
        try storage.empty()
    }
}
