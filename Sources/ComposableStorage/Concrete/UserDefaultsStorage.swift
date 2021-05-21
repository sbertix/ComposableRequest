//
//  UserDefaultsStorage.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `struct` defining a `Storage` caching `Item`s inside `UserDefaults`.
///
/// - warning: **Do not use this in production for caching cookies or other sensible data**.
/// - note: Use `KeycahinStorage` from `ComposableRequestCyprto` for safe storage.
public struct UserDefaultsStorage<Item: Storable>: NonThrowingStorage {
    /// A `UserDefaults` used as storage. Defaults to `.standard`.
    private let userDefaults: UserDefaults

    /// Init.
    ///
    /// - parameter userDefaults: A valid `UserDefaults`. Defaults to `.standard`.
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: Storable

    /// Return the first `Item` matching `label`, `nil` if none was found.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: An optional `Item`.
    public func item(matching label: String) -> Item? {
        userDefaults.data(forKey: label).flatMap { try? Item.decoding($0) }
    }

    /// Return all stored `Item`s.
    ///
    /// - returns: An order collection of `Item`s.
    public func items() -> [Item] {
        userDefaults.dictionaryRepresentation()
            .compactMap { ($0.value as? Data).flatMap { try? Item.decoding($0) } }
    }

    /// Store some `Item`, overwriting the ones matching its `label`.
    ///
    /// - parameter item: A valid `Item`.
    /// - returns: `item`.
    @discardableResult
    public func store(_ item: Item) -> Item {
        guard let data = try? Item.encoding(item) else { return item }
        userDefaults.set(data, forKey: item.label)
        userDefaults.synchronize()
        return item
    }

    /// Return an `Item`, if found, then removes it from storage.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: An optional `Item`.
    @discardableResult
    public func discard(_ label: String) -> Item? {
        defer { userDefaults.removeObject(forKey: label) }
        return item(matching: label)
    }

    /// Empty storage.
    public func empty() {
        items().forEach { discard($0.label) }
        userDefaults.synchronize()
    }
}
