//
//  AnyStorage.swift
//  Storages
//
//  Created by Stefano Bertagno on 17/12/22.
//

import Foundation

/// A `struct` defining a type-erased instance of `Storage`.
public struct AnyStorage<Item: Storable> {
    /// Insert a new item.
    private let _insert: (Item) throws -> (inserted: Bool, memberAfterInsert: Item)
    /// Remove the associated item, if it exists.
    private let _removeValue: (Item.ID) throws -> Item?
    /// Get the associated item, if it exists.
    private let _value: (Item.ID) throws -> Item?
    /// Remove all associated item.
    private let _removeAll: () throws -> Void
    /// The iterator.
    private let _iterator: () -> AnyIterator<Item>

    /// Init.
    ///
    /// - parameter storage: Some `Storage`.
    public init<S: Storage>(_ storage: S) where S.Item == Item {
        self._insert = { try storage.insert($0) }
        self._removeValue = { try storage.removeValue(forKey: $0) }
        self._value = { try storage[$0] }
        self._removeAll = { try storage.removeAll() }
        self._iterator = { AnyIterator(storage.makeIterator()) }
    }
}

extension AnyStorage: Sequence {
    /// Compose the iterator.
    ///
    /// - returns: Some `IteratorProtocol`.
    public func makeIterator() -> AnyIterator<Item> {
        _iterator()
    }
}

extension AnyStorage: Storage {
    /// Insert a new item.
    ///
    /// - parameter item: Some `Item`.
    /// - returns: A tuple indicating whether a previous value existed, and what this value was.
    @discardableResult
    public func insert(_ item: Item) throws -> (inserted: Bool, memberAfterInsert: Item) {
        try _insert(item)
    }

    /// Remove the associated item, if it exists.
    ///
    /// - parameter key: Some `Item.ID`.
    /// - throws: Any `Error`.
    /// - returns: The removed `Item`, if it exists.
    @discardableResult
    public func removeValue(forKey key: Item.ID) throws -> Item? {
        try _removeValue(key)
    }

    /// Remove all associated items.
    public func removeAll() throws {
        try _removeAll()
    }

    /// Get the assocaited item, if it exists.
    ///
    /// - parameter key: Some `Item.ID`.
    /// - throws: Any `Error`.
    /// - returns: Some optional `Item`.
    public subscript(_ key: Item.ID) -> Item? {
        get throws {
            try _value(key)
        }
    }
}
