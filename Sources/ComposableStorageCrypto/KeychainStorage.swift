//
//  KeychainStorage.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

import ComposableStorage
import Swiftchain

/// A `struct` defining a `Storage` caching `Item`s **safely** inside the user's **Keychain**.
public struct KeychainStorage<Item: Storable>: ThrowingStorage {
    /// The underlying keychain.
    private let keychain: Keychain

    /// Init.
    ///
    /// - parameters:
    ///     - service: An optional `String` identifying the service name for the keychain instance.
    ///     - group: An optional `String` identifying the service name for the keychain instance. Defaults to `nil`.
    ///     - accessibility: A valid `Keychain.Accessibility` value. Defaults to `.whenUnlocked`.
    ///     - authentication: A valid `Keychain.Authentication` value. Defaults to empty.
    ///     - isSynchronizable: A `Bool` representing whether the `Secret` should be shared through iCloud Keychain or not. Defaults to `false`.
    public init(service: String? = nil,
                group: String? = nil,
                accessibility: Keychain.Accessibility = .whenUnlocked,
                authentication: Keychain.Authentication = [],
                isSynchronizable: Bool = false) {
        self.keychain = .init(service: service ?? Bundle.main.bundleIdentifier ?? "Swiftagram",
                              group: group,
                              accessibility: accessibility,
                              authentication: authentication,
                              isSynchronizable: isSynchronizable)
    }

    // MARK: Storable

    /// Return the first `Item` matching `label`, `nil` if none was found.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    public func item(matching label: String) throws -> Item? {
        try keychain.container(for: label)
            .fetch()
            .flatMap { try Item.decoding($0) }
    }

    /// Return all stored `Item`s.
    ///
    /// - returns: An order collection of `Item`s.
    /// - throws: Some `Error`.
    public func items() throws -> [Item] {
        try keychain.keys().compactMap(item)
    }

    /// Store some `Item`, overwriting the ones matching its `label`.
    ///
    /// - parameter item: A valid `Item`.
    /// - returns: `item`.
    /// - throws: Some `Error`.
    @discardableResult
    public func store(_ item: Item) throws -> Item {
        try keychain.container(for: item.label).store(Item.encoding(item))
        return item
    }

    /// Return an `Item`, if found, then removes it from storage.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    @discardableResult
    public func discard(_ label: String) throws -> Item? {
        try keychain.container(for: label)
            .drop()
            .flatMap { try Item.decoding($0) }
    }

    /// Empty storage.
    ///
    /// - throws: Some `Error`.
    public func empty() throws {
        try keychain.empty()
    }
}
