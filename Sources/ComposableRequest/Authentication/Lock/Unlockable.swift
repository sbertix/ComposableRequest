//
//  Unlockable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/04/2020.
//

import Foundation

/// A `protocol` defining a `Locked` item in need of authentication.
public protocol Unlockable {
    /// The `Locked` type.
    associatedtype Locked: Lockable

    /// Authenticate with a `Key`.
    /// - parameter key: A valid `Key`.
    /// - returns: An authenticated `Locked`.
    func unlocking(with key: Key) -> Locked
}
