//
//  TransientStorage.swift
//  Storages
//
//  Created by Stefano Bertagno on 07/03/2020.
//

 import Foundation

/// A `struct` defining a `Storage` avoiding caching all together.
 public struct TransientStorage<Item: Storable>: Storage, IteratorProtocol {
    /// Init.
    public init() { }

     /// Insert a new item.
     ///
     /// - parameter item: Some `Item`.
     /// - returns: A tuple indicating whether a previous value existed, and what this value was.
     @discardableResult
     public func insert(_ item: Item) -> (inserted: Bool, memberAfterInsert: Item) {
         (false, item)
     }

     /// Remove the associated item, if it exists.
     ///
     /// - parameter key: Some `Item.ID`.
     /// - throws: Any `Error`.
     /// - returns: The removed `Item`, if it exists.
     @discardableResult
     public func removeValue(forKey key: Item.ID) -> Item? { nil }

     /// Remove all associated items.
     public func removeAll() { }

     /// Return the next value.
     ///
     /// - returns: Some optional `Item`.
     public func next() -> Item? { nil }

     /// Get the assocaited item, if it exists.
     ///
     /// - parameter key: Some `Item.ID`.
     /// - throws: Any `Error`.
     /// - returns: Some optional `Item`.
     public subscript(_ key: Item.ID) -> Item? { nil }
}

public extension Storage {
    /// Compose an instance of `TransientStorage`.
    ///
    /// - returns: An instance of `Self`.
    static func transient<I: Storable>() -> Self where Self == TransientStorage<I> {
        .init()
    }
}
