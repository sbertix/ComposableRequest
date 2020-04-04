//
//  Lockable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/04/2020.
//

import Foundation

/// A `protocol` defining an element requiring a `Secret` to be resolved.
public protocol Lockable {
    /// Update `self` according to the authentication `Secret`.
    /// - parameters:
    ///     - request: An instance of `Self`.
    ///     - secret: A valid `Secret`.
    /// - warning: Do not call directly.
    static func authenticating(_ request: Self, with secret: Secret) -> Self
}

/// Default extensions for `Lockable`.
public extension Lockable {
    /// Lock `self`.
    /// - returns: A `Lock<Self>` instance wrapping `self`.
    func locked() -> Lock<Self> { return .init(request: self) }
}
