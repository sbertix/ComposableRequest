//
//  UserDefaultsStorage.swift
//  Storages
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `struct` defining a `Storage` caching `Item`s in `UserDefaults`.
///
/// - warning: **Do not use this in production for caching cookies or other sensible data**.
/// - note: Use `KeycahinStorage` from `ComposableRequestCyprto` for safe storage.
public struct UserDefaultsStorage<Item: Storable> {
    /// The `UserDefaults` instance backing the storage.
    private let userDefaults: UserDefaults

    /// Init.
    ///
    /// - parameter userDefaults: Some `UserDefaults`. Defaults to `.standard`.
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsStorage: Sequence {
    /// Compose the iterator.
    ///
    /// - returns: Some `IteratorProtocol`.
    public func makeIterator() -> Iterator {
        Iterator(userDefaults: userDefaults)
    }
}

extension UserDefaultsStorage: Storage {
    /// Insert a new item.
    ///
    /// - parameter item: Some `Item`.
    /// - returns: A tuple indicating whether a previous value existed, and what this value was.
    @discardableResult
    public func insert(_ item: Item) throws -> (inserted: Bool, memberAfterInsert: Item) {
        // Prepare the previous value, making
        // sure we do not throw on failures.
        let formerItem = try? self[item.id]
        // Insert the new item.
        try userDefaults.set(item.encoded(), forKey: item.id)
        return (formerItem == nil, formerItem ?? item)
    }

    /// Remove the associated item, if it exists.
    ///
    /// - parameter key: Some `Item.ID`.
    /// - throws: Any `Error`.
    /// - returns: The removed `Item`, if it exists.
    @discardableResult
    public func removeValue(forKey key: Item.ID) throws -> Item? {
        defer { userDefaults.removeObject(forKey: key) }
        // Prepare the previous value, making
        // sure we do not throw on failures.
        return try? self[key]
    }

    /// Get the assocaited item, if it exists.
    ///
    /// - parameter key: Some `Item.ID`.
    /// - throws: Any `Error`.
    /// - returns: Some optional `Item`.
    public subscript(_ key: Item.ID) -> Item? {
        get throws {
            try userDefaults
                .data(forKey: key)
                .flatMap(Item.init(decoding:))
        }
    }
}

public extension UserDefaultsStorage {
    /// A `struct` defining a `UserDefaultsStorage` iterator.
    struct Iterator: IteratorProtocol {
        /// The dictionary representation for the `UserDefaults` backing the storage.
        private let userDefaults: [String: Any]
        /// The current offset.
        private var offset: Dictionary<String, Any>.Index

        /// Init.
        ///
        /// - parameter userDefaults: Some `UserDefaults`.
        init(userDefaults: UserDefaults) {
            self.userDefaults = userDefaults.dictionaryRepresentation()
            self.offset = self.userDefaults.startIndex
        }

        /// Return the next value.
        ///
        /// - returns: Some optional `Item`.
        public mutating func next() -> Item? {
            // Return the first value actually
            // encoding an `Item` instance.
            var item: Item?
            repeat {
                // Make sure we're withing bounds.
                guard offset < userDefaults.endIndex else { break }
                // Find the item and attempt to decode it.
                item = try? (userDefaults[offset].value as? Data).flatMap(Item.init(decoding:))
                offset = userDefaults.index(after: offset)
            } while item == nil
            // Return the first match,
            // or `nil` if none can be found.
            return item
        }
    }
}

public extension Storage {
    /// Compose an instance of `UserDefaultsStorage`.
    ///
    /// - parameter userDefaults: Some `UserDefaults`. Defaults to `.standard`.
    /// - returns: An instance of `Self`.
    static func userDefaults<I: Storable>(_ userDefaults: UserDefaults = .standard) -> Self
    where Self == UserDefaultsStorage<I> {
        .init(userDefaults: userDefaults)
    }
}
