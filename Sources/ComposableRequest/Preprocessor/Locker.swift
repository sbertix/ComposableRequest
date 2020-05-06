//
//  Locker.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Foundation

/// A `struct` defining custom `Preprocessor` for authentication.
public struct Locker<Request: Fetchable & Preprocessable, Secret: Key> {
    /// An `enum` holding reference to standard lock types.
    public enum Condition {
        /// Through body.
        case body
        /// Through header fields.
        case header
        /// Through query. Not recommended.
        case query
    }
    
    /// A `typealias` for the unlocking function.
    public typealias Unlocker = (_ request: Request.Preprocessed, _ secret: Secret) -> Request.Preprocessed
    
    /// The underlying `Request`.
    internal private(set) var request: Request
    /// The `Unlocker`.
    internal private(set) var unlocker: Unlocker
    
    /// Init.
    /// - parameters:
    ///     - request: A valid `Request`.
    ///     - unlocker: A valid `Unlocker`.
    internal init(request: Request, unlocker: @escaping Unlocker) {
        self.request = request
        self.unlocker = unlocker
    }
    
    /// Unlock with `secret`.
    /// - parameter secret: A valid `Secret`.
    /// - returns: An updated fixed `Request`.
    public func unlocking(with secret: Secret) -> Request {
        return request.appending { self.unlocker($0, secret) }
    }
}
