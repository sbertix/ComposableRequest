//
//  Manifest.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// A `protocol` defining an expected `Response` type, for a specific `Request`.
public protocol Manifest {
    /// An associated `Request` type.
    associatedtype Request
    /// An associated `Response` type.
    associatedtype Response
    
    /// Compute the next `Request`, from the current one and a possible response.
    /// - parameters:
    ///     - request: The last valid `Request`.
    ///     - result: An optional `Result` for the last valid `Response`. Defaults to `nil`.
    /// - returns: `nil` if no next `Request` should be returned, the next `Request` otherwise.
    func `continue`(from request: Request, processing result: Result<Response, Error>?) -> Request?
}

/// A `protocol` defining a `Manifest` that never continues.
public protocol DisposableManifest: Manifest { }
public extension DisposableManifest {
    /// Always returns `nil`.
    /// - parameters:
    ///     - request: The last valid `Request`.
    ///     - result: An optional `Result` for the last valid `Response`. Defaults to `nil`.
    /// - returns: `nil`.
    func `continue`(from request: Request, processing result: Result<Response, Error>?) -> Request? {
        return nil
    }
}
