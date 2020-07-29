//
//  Lockable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Foundation

/// A `protocol` describing things that can be put into a `Locker`.
public protocol Lockable: Preprocessable { }

/// An `extension` to allow for requiring authentication.
public extension Lockable {
    /// Return a `Locker`.
    /// - parameters:
    ///     - secret: A `Key` metatype.
    ///     - unlocker: A valid `Unlocker`.
    /// - returns: A `Locker` unwrapping `self`.
    func locking<Secret: Key>(_ secret: Secret.Type,
                              with unlocker: @escaping Locker<Self, Secret>.Unlocker) -> Locker<Self, Secret> {
        return .init(request: self, unlocker: unlocker)
    }

    /// Return a `Locker`.
    /// - parameter unlocker: A valid `Unlocker`.
    /// - returns: A `Locker` unwrapping `self`.
    func locking(with unlocker: @escaping Locker<Self, AnyCookieKey>.Unlocker) -> Locker<Self, AnyCookieKey> {
        return locking(AnyCookieKey.self, with: unlocker)
    }
}

public extension Lockable where Preprocessed: HeaderComposable & HeaderParsable {
    /// Return a `Locker` using the `header` as `Unlocker`.
    /// - parameter secret: A `Key` metatype.
    /// - returns: A `Locker` unwrapping `self`.
    func locking<Secret>(_ secret: Secret.Type) -> Locker<Self, Secret> where Secret: HeaderKey {
        return locking(Secret.self, with: { $0.appending(header: $1.header) })
    }

    /// Return a `Locker` using the `header` as `Unlocker`.
    /// - returns: A `Locker` unwrapping `self`.
    func locking() -> Locker<Self, AnyCookieKey> {
        return locking(AnyCookieKey.self)
    }
}
