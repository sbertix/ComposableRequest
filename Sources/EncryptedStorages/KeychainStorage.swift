//
//  KeychainStorage.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

import KeychainAccess
import protocol Storages.Storable
import protocol Storages.Storage

/// A `typealias` for `KeychainAccess.Keychain`.
public typealias Keychain = KeychainAccess.Keychain
/// A `typealias` for `KeychainAccess.Accessibility`.
public typealias Accessibility = KeychainAccess.Accessibility
/// A `typealias` for `KeychainAccess.AuthenticationPolicy`.
public typealias AuthenticationPolicy = KeychainAccess.AuthenticationPolicy

/// A `struct` defining a `Storage` caching `Item`s **safely** inside the user's **Keychain**.
public struct KeychainStorage<Item: Storable> {
    /// The underlying keychain.
    private let keychain: Keychain

    #if os(watchOS)
    /// Init.
    ///
    /// - parameters:
    ///     - service: An optional `String` identifying the service name for the keychain instance.
    ///     - group: An optional `String` identifying the service name for the keychain instance. Defaults to `nil`.
    ///     - accessibility: A valid `Accessibility` value. Defaults to `.whenUnlocked`.
    ///     - isSynchronizable: A `Bool` representing whether the `Secret` should be shared through iCloud Keychain or not. Defaults to `false`.
    public init(
        service: String? = nil,
        group: String? = nil,
        accessibility: Accessibility = .whenUnlocked,
        isSynchronizable: Bool = false
    ) {
        let service = service ?? Bundle.main.bundleIdentifier ?? "Swiftagram"
        self.keychain = (group.flatMap { Keychain(service: service, accessGroup: $0) } ?? Keychain(service: service))
            .synchronizable(isSynchronizable)
            .accessibility(accessibility)
    }
    #else
    /// Init.
    ///
    /// - parameters:
    ///     - service: An optional `String` identifying the service name for the keychain instance.
    ///     - group: An optional `String` identifying the service name for the keychain instance. Defaults to `nil`.
    ///     - accessibility: A valid `Accessibility` value. Defaults to `.whenUnlocked`.
    ///     - authentication: A valid `Authentication` value. Defaults to empty.
    ///     - isSynchronizable: A `Bool` representing whether the `Secret` should be shared through iCloud Keychain or not. Defaults to `false`.
    public init(
        service: String? = nil,
        group: String? = nil,
        accessibility: Accessibility = .whenUnlocked,
        authentication: AuthenticationPolicy = [],
        isSynchronizable: Bool = false
    ) {
        let service = service ?? Bundle.main.bundleIdentifier ?? "Swiftagram"
        self.keychain = (group.flatMap { Keychain(service: service, accessGroup: $0) } ?? Keychain(service: service))
            .synchronizable(isSynchronizable)
            .accessibility(accessibility, authenticationPolicy: authentication)
    }
    #endif
}

extension KeychainStorage: Sequence {
    /// Compose the iterator.
    ///
    /// - returns: Some `IteratorProtocol`.
    public func makeIterator() -> Iterator {
        Iterator(keychain: keychain)
    }
}

extension KeychainStorage: Storage {
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
        try keychain.set(item.encoded(), key: item.id)
        return (formerItem == nil, formerItem ?? item)
    }

    /// Remove the associated item, if it exists.
    ///
    /// - parameter key: Some `Item.ID`.
    /// - throws: Any `Error`.
    /// - returns: The removed `Item`, if it exists.
    @discardableResult
    public func removeValue(forKey key: Item.ID) throws -> Item? {
        // Prepare the previous value, making
        // sure we do not throw on failures.
        let formerItem = try? self[key]
        // Remove the item.
        try keychain.remove(key)
        return formerItem
    }

    /// Get the assocaited item, if it exists.
    ///
    /// - parameter key: Some `Item.ID`.
    /// - throws: Any `Error`.
    /// - returns: Some optional `Item`.
    public subscript(_ key: Item.ID) -> Item? {
        get throws {
            try keychain
                .getData(key)
                .flatMap(Item.init(decoding:))
        }
    }
}

public extension KeychainStorage {
    /// A `struct` defining a `KeychainStorage` iterator.
    struct Iterator: IteratorProtocol {
        /// The underlying keychain instance.
        private let keychain: Keychain
        /// The keys inside the keychain.
        private let keys: [String]
        /// The current offset.
        private var offset: Array<String>.Index

        /// Init.
        ///
        /// - parameter keychain: Some `Keychain`.
        init(keychain: Keychain) {
            self.keychain = keychain
            self.keys = keychain.allKeys()
            self.offset = self.keys.startIndex
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
                guard offset < keys.endIndex else { break }
                // Find the item and attempt to decode it.
                item = try? keychain.getData(keys[offset]).flatMap(Item.init(decoding:))
                offset = keys.index(after: offset)
            } while item == nil
            // Return the first match,
            // or `nil` if none can be found.
            return item
        }
    }
}

public extension Storage {
    #if os(watchOS)
    /// Compose an instance of `KeychainStorage`.
    ///
    /// - parameters:
    ///     - service: An optional `String` identifying the service name for the keychain instance.
    ///     - group: An optional `String` identifying the service name for the keychain instance. Defaults to `nil`.
    ///     - accessibility: A valid `Accessibility` value. Defaults to `.whenUnlocked`.
    ///     - isSynchronizable: A `Bool` representing whether the `Secret` should be shared through iCloud Keychain or not. Defaults to `false`.
    static func keychain<I: Storable>(
        service: String? = nil,
        group: String? = nil,
        accessibility: Accessibility = .whenUnlocked,
        isSynchronizable: Bool = false
    ) -> Self where Self == KeychainStorage<I> {
        .init(
            service: service,
            group: group,
            accessibility: accessibility,
            isSynchronizable: isSynchronizable
        )
    }
    #else
    /// Compose an instance of `KeychainStorage`.
    ///
    /// - parameters:
    ///     - service: An optional `String` identifying the service name for the keychain instance.
    ///     - group: An optional `String` identifying the service name for the keychain instance. Defaults to `nil`.
    ///     - accessibility: A valid `Accessibility` value. Defaults to `.whenUnlocked`.
    ///     - authentication: A valid `Authentication` value. Defaults to empty.
    ///     - isSynchronizable: A `Bool` representing whether the `Secret` should be shared through iCloud Keychain or not. Defaults to `false`.
    static func keychain<I: Storable>(
        service: String? = nil,
        group: String? = nil,
        accessibility: Accessibility = .whenUnlocked,
        authentication: AuthenticationPolicy = [],
        isSynchronizable: Bool = false
    ) -> Self where Self == KeychainStorage<I> {
        .init(
            service: service,
            group: group,
            accessibility: accessibility,
            authentication: authentication,
            isSynchronizable: isSynchronizable
        )
    }
    #endif
}
