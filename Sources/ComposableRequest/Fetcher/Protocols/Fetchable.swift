//
//  Fetchable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// A `protocol` descrbing a request that can be fetched by a `Fetcher`.
public protocol Fetchable {
    /// Computes (if needed) the associated `URLRequest` and returns it.
    /// - returns: A valid `URLRequest` or `nil`.
    func request() -> URLRequest?
}

/// Default extension for `Fetchable` to construct `Fetcher`s.
public extension Fetchable {
    /// Returns a `Fetcher`.
    /// - parameters:
    ///     - map: A valid `Fetcher.Map`
    ///     - next: An optional `Fetcher.Next`.
    /// - returns: A `Fetcher` wrapping `self`.
    func prepare<Response>(map: @escaping Fetcher<Self, Response>.Map,
                           cycling next: @escaping Fetcher<Self, Response>.Next) -> Fetcher<Self, Response> {
        return .init(request: self, map: map, next: next)
    }
    
    /// Returns a `Fetcher`.
    /// - parameter next: An optional `Fetcher.Next`.
    /// - returns: A `Fetcher` wrapping `self`.
    func prepare(cycling next: @escaping Fetcher<Self, Response>.Next) -> Fetcher<Self, Response> {
        return prepare(map: { try JSONDecoder().decode(Response.self, from: $0) }, cycling: next)
    }
    
    /// Returns a `DisposableFetcher`.
    /// - parameter response: A `Response` metatype.
    /// - returns: A `DisposableFetcher` wrapping `self`.
    func prepare<Response>(map: @escaping Fetcher<Self, Response>.Map) -> DisposableFetcher<Self, Response> {
        return .init(request: self, map: map)
    }
    
    /// Returns a `DisposableFetcher`.
    /// - returns: A `DisposableFetcher` wrapping `self`.
    func prepare() -> DisposableFetcher<Self, ComposableRequest.Response> {
        return prepare { try JSONDecoder().decode(Response.self, from: $0) }
    }
}
