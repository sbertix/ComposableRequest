//
//  TransientStorage.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `struct` defining a `Storage` avoiding caching all together.
public struct TransientStorage<Item: Storable>: NonThrowingStorage {
    /// Init.
    public init() { }

    // MARK: Storable

    /// Return the first `Item` matching `label`, `nil` if none was found.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: An optional `Item`.
    public func item(matching label: String) -> Item? { nil }

    /// Return all stored `Item`s.
    ///
    /// - returns: An order collection of `Item`s.
    public func items() -> [Item] { [] }

    /// Store some `Item`, overwriting the ones matching its `label`.
    ///
    /// - parameter item: A valid `Item`.
    /// - returns: `item`.
    @discardableResult
    public func store(_ item: Item) -> Item { item }

    /// Return an `Item`, if found, then removes it from storage.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: An optional `Item`.
    @discardableResult
    public func discard(_ label: String) -> Item? { nil }

    /// Empty storage.
    public func empty() { }
}
