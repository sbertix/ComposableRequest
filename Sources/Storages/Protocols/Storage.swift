//
//  Storage.swift
//  Storages
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `protocol` defining an instance capble of caching `Storable`s.
public protocol Storage<Item>: Sequence where Element == Item {
    /// The associated item type.
    associatedtype Item: Storable

    /// Insert a new item.
    ///
    /// - parameter item: Some `Item`.
    /// - throws: Any `Error`.
    /// - returns: A tuple indicating whether a previous value existed, and what this value was.
    @discardableResult
    func insert(_ item: Item) throws -> (inserted: Bool, memberAfterInsert: Item)

    /// Remove the associated item, if it exists.
    ///
    /// - parameter key: Some `Item.ID`.
    /// - throws: Any `Error`.
    /// - returns: The removed `Item`, if it exists.
    @discardableResult
    func removeValue(forKey key: Item.ID) throws -> Item?

    /// Remove all associated items.
    func removeAll() throws

    /// Get the assocaited item, if it exists.
    ///
    /// - parameter key: Some `Item.ID`.
    /// - throws: Any `Error`.
    /// - returns: Some optional `Item`.
    subscript(_ key: Item.ID) -> Item? { get throws }
}

public extension Storage {
    /// Remove all associated items.
    func removeAll() throws {
        for item in self {
            try removeValue(forKey: item.id)
        }
    }

    /// Type-erase the current instance.
    ///
    /// - returns: A valid `AnyStorage`.
    func eraseToAnyStorage() -> AnyStorage<Item> {
        .init(self)
    }
}
