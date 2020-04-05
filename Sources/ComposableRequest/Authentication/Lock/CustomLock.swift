//
//  CustomLock.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/04/2020.
//

import Foundation

/// A `struct` holding reference to a user-defined `Unlockable`.
public struct CustomLock<Locked: Lockable>: Unlockable {
    /// The original `Locked`.
    internal var request: Locked
    /// The authenticator.
    public var authenticator: (Locked, Secret) -> Locked

    /// Init.
    /// - parameter request: A valid `Lockable`.
    public init(request: Locked, authenticator: @escaping (Locked, Secret) -> Locked) {
        self.request = request
        self.authenticator = authenticator
    }

    /// Authenticate with a `Secret`.
    /// - parameter secret: A valid `Secret`.
    /// - returns: An authenticated `Request`.
    public func authenticating(with secret: Secret) -> Locked { return authenticator(request, secret) }
}

// MARK: Composable
extension CustomLock: Composable where Locked: Composable { }
extension CustomLock: WrappedComposable where Locked: Composable {
    /// A valid `Composable`.
    public var composable: Locked {
        get { return request }
        set { request = newValue }
    }
}

// MARK: Expecting
extension CustomLock: Expecting where Locked: Expecting {
    /// The associated `Response` type.
    public typealias Response = Locked.Response
}
extension CustomLock: Singular where Locked: Singular { }
extension CustomLock: Paginatable where Locked: Paginatable {
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
    /// Additional parameters for the header fields, based on the last `Response`.
    public var nextHeader: ((Result<Response, Error>) -> [String: String?]?)? {
        get { return request.nextHeader }
        set { request.nextHeader = newValue }
    }
    /// Additional parameters for the body, based on the last `Response`.
    public var nextBody: ((Result<Response, Error>) -> [String: String?]?)? {
        get { return request.nextBody }
        set { request.nextBody = newValue }
    }
}
