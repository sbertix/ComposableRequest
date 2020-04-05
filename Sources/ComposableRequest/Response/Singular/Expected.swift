//
//  Expected.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `struct` for changing the expected `Response`.
public struct Expected<Request: Expecting, Response: DataMappable>: Singular {
    /// The associated expectation.
    public var expecting: Request
}

// MARK: Composable
extension Expected: Composable where Request: Composable { }
extension Expected: WrappedComposable where Request: Composable {
    /// A valid `Composable`.
    public var composable: Request {
        get { return expecting }
        set { expecting = newValue }
    }
}

// MARK: Requestable
extension Expected: Requestable where Request: Requestable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? { return expecting.request() }
}

// MARK: Lockable
extension Expected: Lockable where Request: Lockable { }

// MARK: Unlockable
extension Expected: Unlockable where Request: Unlockable, Request.Locked: Expecting {
    /// Authenticate with a `Secret`.
    /// - parameter secret: A valid `Secret`.
    /// - returns: An authenticated `Request`.
    public func authenticating(with secret: Secret) -> Expected<Request.Locked, Response> {
        return .init(expecting: expecting.authenticating(with: secret))
    }
}
