//
//  Lockable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `protocol` defining an element requiring a `Secret` to be resolved.
public protocol Lockable {
    /// Update as the `Unlockable` was unloacked.
    /// - parameters:
    ///     - unlockable: A valid `Unlockable`.
    ///     - secrets:  A `Dictionary` of `String` representing the authentication header fields.
    /// - warning: Do not call directly.
    static func unlock(_ unlockable: Locked<Self>, with secrets: [String: String]) -> Self
}

/// Default extensions for `Lockable`.
public extension Lockable {
    /// Lock `self` until a `Secret` is used for authenticating the request.
    /// - returns: A `Locked<Self>` value wrapping `self`.
    func locked() -> Locked<Self> { return .init(lockable: self) }
}

/// A `protocol` defining an element allowing for authentication.
public protocol Unlockable {
    /// The associated `Lockable`.
    associatedtype Locked: Lockable

    /// Unlock the underlying `Locked`.
    /// - parameter secrets: A `Dictionary` of `String` representing the authentication header fields.
    func authenticating(with secrets: [String: String]) -> Locked
}

/// Default extensions for `Unlockable`.
public extension Unlockable {
    /// Unlock the underlying `Locked`.
    /// - parameter secret: A valid `Secret`.
    func authenticating<Secret: Secreted>(with secret: Secret) -> Locked {
        return authenticating(with: secret.headerFields)
    }
}
