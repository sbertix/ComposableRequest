//
//  Lockable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/04/2020.
//

import Foundation

/// A `protocol` defining an element requiring a `Secret` to be resolved.
public protocol Lockable { }

/// Default extensions for `Lockable`.
public extension Lockable {
    /// Lock `self`.
    /// - parameter unlockable: A concrete type conforming to `CustomUnlockable`.
    /// - returns: An instance of `Unlockable` wrapping `self`.
    func locking<Unlockable: CustomUnlockable>(into unlockable: Unlockable.Type) -> Unlockable where Unlockable.Locked == Self {
        return Unlockable(request: self)
    }
}

/// Default extensions for `Lockable & Composable`.
public extension Lockable where Self: Composable {
    /// Lock `self`.
    /// - returns: A `Lock<Self>` instance wrapping `self`.
    /// - note: Prefer calling `locking(into: Lock.self)` directly. This might be removed soon.
    func locked() -> Lock<Self> { return locking(into: Lock.self) }
}
