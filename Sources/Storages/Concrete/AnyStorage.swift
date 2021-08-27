//
//  AnyStorage.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 10/04/21.
//

import Foundation

/// A `struct` defining a type-erased `Storage`.
public struct AnyStorage<Item: Storable>: Storage {
    /// Retreive a single item.
    private let retreiver: (String) throws -> Item?
    /// Retreieve all items.
    private let exhauster: () throws -> [Item]
    /// Store a single item.
    private let persister: (Item) throws -> Item
    /// Discard a single item.
    private let remover: (String) throws -> Item?
    /// Wipe the entire storage.
    private let wiper: () throws -> Void

    /// Init.
    ///
    /// - parameter storage: A valid `Storage`.
    public init<S: Storage>(_ storage: S) where S.Item == Item {
        self.retreiver = { try S.item(matching: $0, in: storage) }
        self.exhauster = { try S.items(in: storage) }
        self.persister = { try S.store($0, in: storage) }
        self.remover = { try S.discard($0, in: storage) }
        self.wiper = { try S.empty(storage) }
    }

    /// Return the first `Item` matching `label`, `nil` if none was found.
    ///
    /// - parameters:
    ///     - label: A valid `String`.
    ///     - storage: A valid `Storage`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    public static func item(matching label: String, in storage: Self) throws -> Item? {
        try storage.retreiver(label)
    }

    /// Return all stored `Item`s.
    ///
    /// - parameter storage: A valid `Storage`.
    /// - returns: An order collection of `Item`s.
    /// - throws: Some `Error`.
    public static func items(in storage: Self) throws -> [Item] {
        try storage.exhauster()
    }

    /// Store some `Item`, overwriting the ones matching its `label`.
    ///
    /// - parameters:
    ///     - item: A valid `Item`.
    ///     - storage: A valid `Storage`.
    /// - returns: `item`.
    /// - throws: Some `Error`.
    @discardableResult
    public static func store(_ item: Item, in storage: Self) throws -> Item {
        try storage.persister(item)
    }

    /// Return an `Item`, if found, then removes it from storage.
    ///
    /// - parameters:
    ///     - label: A valid `String`.
    ///     - storage: A valid `Storage`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    @discardableResult
    public static func discard(_ label: String, in storage: Self) throws -> Item? {
        try storage.remover(label)
    }

    /// Empty storage.
    ///
    /// - parameter storage: A valid `Storage`.
    /// - throws: Some `Error`.
    public static func empty(_ storage: Self) throws {
        try storage.wiper()
    }
}
