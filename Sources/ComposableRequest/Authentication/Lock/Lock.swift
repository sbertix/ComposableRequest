//
//  Lock.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/04/2020.
//

import Foundation

/// A `struct` holding reference to a user-defined `Unlockable`.
public struct Lock<Locked: Lockable>: Unlockable {
    /// The original `Locked`.
    internal var request: Locked
    /// The authenticator.
    public var authenticator: Authenticator<Locked>

    /// Init.
    /// - parameters:
    ///     - request: A valid `Lockable`.
    ///     - authenticator: A block accepting a valid `Unlocking` and returning `Locked`.
    public init(request: Locked, authenticator: @escaping Authenticator<Locked>) {
        self.request = request
        self.authenticator = authenticator
    }

    /// Authenticate with a `Key`.
    /// - parameter key: A valid `Key`.
    /// - returns: An authenticated `Request`.
    public func unlocking(with key: Key) -> Locked {
        return authenticator(.init(request: request, key: key))
    }
}

// MARK: Composable
extension Lock: Composable, WrappedComposable where Locked: Composable {
    /// A valid `Composable`.
    public var composable: Locked {
        get { return request }
        set { request = newValue }
    }
}

// MARK: Expecting
extension Lock: Expecting where Locked: Expecting {
    /// The associated `Response` type.
    public typealias Response = Locked.Response
}
extension Lock: Singular where Locked: Singular { }
extension Lock: Paginatable, WrappedPaginatable where Locked: Paginatable {
    /// A valid `Paginatable`.
    public var paginatable: Locked {
        get { return request }
        set { request = newValue }
    }
}
