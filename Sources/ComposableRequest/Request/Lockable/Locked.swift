//
//  Locked.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `struct` locking a `Lockable` until a `Secret` is passed to it.
public struct Locked<Lockable: ComposableRequest.Lockable>: Unlockable {
    /// A valid `Lockable`.
    public var lockable: Lockable

    /// Init.
    /// - parameter lockable: A valid `Lockable`.
    /// - note: use `lockable.locked()` instead.
    internal init(lockable: Lockable) { self.lockable = lockable }

    // MARK: Resolve
    /// Unlock the underlying `Lockable`.
    /// - parameter secrets: A `Dictionary` of `String` representing the authentication header fields.
    public func authenticating(with secrets: [String: String]) -> Lockable {
        return Lockable.unlock(self, with: secrets)
    }
}

/// Conditional conformacies to `Expecting`.
extension Locked: Expecting where Lockable: Expecting {
    /// The associated `Response` type.
    public typealias Response = Lockable.Response
}
extension Locked: Singular where Lockable: Singular { }
extension Locked: Paginatable where Lockable: Paginatable {
    /// The `name` of the `URLQueryItem` used for paginating.
    public var key: String {
        get { return lockable.key }
        set { lockable.key = newValue }
    }

    /// The inital `value` of the `URLQueryItem` used for paginating.
    public var initial: String? {
        get { return lockable.initial }
        set { lockable.initial = newValue }
    }

    /// The next `value` of the `URLQueryItem` user for paginating, based on the last `Response`.
    public var next: (Result<Lockable.Response, Error>) -> String? {
        get { return lockable.next }
        set { lockable.next = newValue }
    }
}

/// Conditional conformacies to `Composable`.
extension Locked: Composable where Lockable: Composable { }
extension Locked: WrappedComposable where Lockable: Composable {
    /// A valid `Composable`.
    public var composable: Lockable {
        get { return lockable }
        set { lockable = newValue }
    }
}
