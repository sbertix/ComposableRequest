//
//  Lockable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/04/2020.
//

import Foundation

/// A `protocol` defining an element requiring a `Key` to be resolved.
public protocol Lockable { }

/// Default extensions for `Lockable`.
public extension Lockable {
    /// Lock `self`.
    /// - parameter authenticator: A `block` accepting `Unlocking` and processing `Self` accordingly.
    /// - returns: An instance of `Lock` wrapping `self`.
    /// - note: We suggest extending `Unlocking` with custom properties, e.g. `locking(authenticator: \.header)`.
    func locking(authenticator: @escaping Authenticator<Self>) -> Lock<Self> {
        return Lock(request: self, authenticator: authenticator)
    }

    #if swift(<5.2)
    /// Lock `self`.
    /// - parameter keyPath: A `KeyPath` on `Unlocking` returning `Self`.
    /// - returns: An instance of `Lock` wrapping `self`.
    /// - note: We suggest extending `Unlocking` with custom properties, e.g. `locking(authenticator: \.header)`.
    func locking(authenticator keyPath: KeyPath<Unlocking<Self>, Self>) -> Lock<Self> {
        return Lock(request: self) { $0[keyPath: keyPath] }
    }
    #endif
}
