//
//  Lock.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/04/2020.
//

import Foundation

/// A `struct` holding reference to a `Locked` in need of authentication.
public struct Lock<Locked: Lockable>: CustomUnlockable where Locked: Composable {
    /// The original `Locked`.
    internal var request: Locked

    /// Init.
    /// - parameter request: A valid `Lockable`.
    public init(request: Locked) { self.request = request }

    /// Authenticate with a `Secret`.
    /// - parameter secret: A valid `Secret`.
    /// - returns: An authenticated `Request`.
    public func authenticating(with secret: Secret) -> Locked {
        return request.header(secret.headerFields).body(secret.body)
    }
}

// MARK: Composable
extension Lock: Composable where Locked: Composable { }
extension Lock: WrappedComposable where Locked: Composable {
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
extension Lock: Paginatable where Locked: Paginatable {
    /// The `name` of the `URLQueryItem` used for paginating.
    public var key: String {
        get { return request.key }
        set { request.key = newValue }
    }
    /// The inital `value` of the `URLQueryItem` used for paginating.
    public var initial: String? {
        get { return request.initial }
        set { request.initial = newValue }
    }
    /// The next `value` of the `URLQueryItem` user for paginating, based on the last `Response`.
    public var next: (Result<Response, Error>) -> String? {
        get { return request.next }
        set { request.next = newValue }
    }
}
