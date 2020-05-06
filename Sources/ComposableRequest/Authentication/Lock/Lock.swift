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
extension Lock: WrappedBodyComposable, BodyComposable where Locked: BodyComposable {
    public var bodyComposable: Locked { get { return request } set { request = newValue }}
}
extension Lock: WrappedHeaderComposable, HeaderComposable where Locked: HeaderComposable {
    public var headerComposable: Locked { get { return request } set { request = newValue }}
}
extension Lock: WrappedMethodComposable, MethodComposable where Locked: MethodComposable {
    public var methodComposable: Locked { get { return request } set { request = newValue }}
}
extension Lock: WrappedPathComposable, PathComposable where Locked: PathComposable {
    public var pathComposable: Locked { get { return request } set { request = newValue }}
}
extension Lock: WrappedQueryComposable, QueryComposable where Locked: QueryComposable {
    public var queryComposable: Locked { get { return request } set { request = newValue }}
}
