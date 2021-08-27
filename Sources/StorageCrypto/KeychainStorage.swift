//
//  KeychainStorage.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

import KeychainAccess
import protocol Storage.Storable
import protocol Storage.ThrowingStorage

/// A `typealias` for `KeychainAccess.Keychain`.
///
/// - note:
///     We prefer this to `import @_exported`, as we can't guarantee `@_exported`
///     to stick with future versions of **Swift**.
public typealias Keychain = KeychainAccess.Keychain

/// A `typealias` for `KeychainAccess.Accessibility`.
///
/// - note:
///     We prefer this to `import @_exported`, as we can't guarantee `@_exported`
///     to stick with future versions of **Swift**.
public typealias Accessibility = KeychainAccess.Accessibility

/// A `typealias` for `KeychainAccess.AuthenticationPolicy`.
///
/// - note:
///     We prefer this to `import @_exported`, as we can't guarantee `@_exported`
///     to stick with future versions of **Swift**.
public typealias AuthenticationPolicy = KeychainAccess.AuthenticationPolicy

/// A `struct` defining a `Storage` caching `Item`s **safely** inside the user's **Keychain**.
public struct KeychainStorage<Item: Storable>: ThrowingStorage {
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
    public init(service: String? = nil,
                group: String? = nil,
                accessibility: Accessibility = .whenUnlocked,
                isSynchronizable: Bool = false) {
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
    public init(service: String? = nil,
                group: String? = nil,
                accessibility: Accessibility = .whenUnlocked,
                authentication: AuthenticationPolicy = [],
                isSynchronizable: Bool = false) {
        let service = service ?? Bundle.main.bundleIdentifier ?? "Swiftagram"
        self.keychain = (group.flatMap { Keychain(service: service, accessGroup: $0) } ?? Keychain(service: service))
            .synchronizable(isSynchronizable)
            .accessibility(accessibility, authenticationPolicy: authentication)
    }
    #endif

    // MARK: Storable

    /// Return the first `Item` matching `label`, `nil` if none was found.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    public func item(matching label: String) throws -> Item? {
        try keychain.getData(label).flatMap { try? Item.decoding($0) }
    }

    /// Return all stored `Item`s.
    ///
    /// - returns: An order collection of `Item`s.
    /// - throws: Some `Error`.
    public func items() throws -> [Item] {
        try keychain.allKeys().compactMap(item)
    }

    /// Store some `Item`, overwriting the ones matching its `label`.
    ///
    /// - parameter item: A valid `Item`.
    /// - returns: `item`.
    /// - throws: Some `Error`.
    @discardableResult
    public func store(_ item: Item) throws -> Item {
        try keychain.set(Item.encoding(item), key: item.label)
        return item
    }

    /// Return an `Item`, if found, then removes it from storage.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    @discardableResult
    public func discard(_ label: String) throws -> Item? {
        guard let item = try? item(matching: label) else { return nil }
        try keychain.remove(label)
        return item
    }

    /// Empty storage.
    ///
    /// - throws: Some `Error`.
    public func empty() throws {
        // Delete matching `Storables`.
        let labels = try items().map(\.label)
        guard labels.isEmpty else { return }
        try labels.forEach { try keychain.remove($0) }
    }
}
