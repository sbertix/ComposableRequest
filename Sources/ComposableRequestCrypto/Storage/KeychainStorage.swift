//
//  KeychainStorage.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

import ComposableRequest
import Swiftchain

/// A `struct` holding reference to all `Secret`s stored in the keychain.
/// - note: `
///     KeychainStorage` is the encoded and ready-to-use alternative to `UserDefaultsStorage`.
public struct KeychainStorage<Secret: Key>: Storage {
    /// The underlying keychain.
    private let keychain: Keychain

    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - accessibility: A valid `Keychain.Accessibility` value. Defaults to `.whenUnlocked`.
    ///     - isSynchronizable: A `Bool` representing whether the `Secret` should be shared through iCloud Keychain or not. Defaults to `false`.
    public init(accessibility: Keychain.Accessibility = .whenUnlocked,
                isSynchronizable: Bool = false) {
        self.keychain = .init(accessibility: accessibility, isSynchronizable: isSynchronizable)
    }

    /// Init.
    /// - parameters:
    ///     - service: A `String` identifying the service name for the keychain instance.
    ///     - group: An optional `String` identifying the service name for the keychain instance. Defaults to `nil`.
    ///     - accessibility: A valid `Keychain.Accessibility` value. Defaults to `.whenUnlocked`.
    ///     - isSynchronizable: A `Bool` representing whether the `Secret` should be shared through iCloud Keychain or not. Defaults to `false`.
    public init(service: String,
                group: String? = nil,
                accessibility: Keychain.Accessibility = .whenUnlocked,
                isSynchronizable: Bool = false) {
        self.keychain = .init(service: service,
                              group: group,
                              accessibility: accessibility,
                              isSynchronizable: isSynchronizable)
    }

    // MARK: Lookup
    /// Find a `Secret` stored in the keychain.
    /// - returns: A `Secret` or `nil` if no response could be found.
    /// - note: Use `Secret.stored` to access it.
    public func find(matching identifier: String) -> Secret? {
        return try? keychain
            .get(forKey: identifier)
            .flatMap { try? JSONDecoder().decode(Secret.self, from: $0) }
    }

    /// Return all `Secret`s stored in the `keychain`.
    /// - returns: An `Array` of `Secret`s stored in the `keychain`.
    public func all() -> [Secret] {
        return (try? keychain.allKeys())?.compactMap(find) ?? []
    }

    // MARK: Locker
    /// Store a `Secret` in the keychain.
    /// - note: Prefer `Secret.store` to access it.
    public func store(_ response: Secret) {
        // Store.
        guard let data = try? JSONEncoder().encode(response) else { return }
        try? keychain.set(data, forKey: response.id)
    }

    /// Delete a `Secret` in the keychain.
    /// - returns: The removed `Secret` or `nil` if none was found.
    @discardableResult
    public func remove(matching identifier: String) -> Secret? {
        guard let response = find(matching: identifier) else { return nil }
        try? keychain.remove(matchingKey: identifier)
        return response
    }

    /// Delete all cached `Secret`s.
    public func removeAll() {
        try? keychain.removeAll()
    }
}
