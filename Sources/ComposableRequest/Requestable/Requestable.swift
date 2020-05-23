//
//  Requestable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// A `protocol` descrbing a request that can be fetched by a `Fetcher`.
public protocol Requestable {
    /// Computes (if needed) the associated `URLRequest` and returns it.
    /// - returns: A valid `URLRequest` or `nil`.
    func request() -> URLRequest?
}

/// Default extension for `OldFetchable` to construct `Fetcher`s.
public extension Requestable {
    /// Returns a `Fetcher.Paginated`.
    /// - parameters:
    ///     - preprocessor: An optional `Preprocessor`.
    ///     - processor: A valid `Processor`.
    ///     - pager: A valid `Pager`.
    /// - returns: A `Fetcher.Paginated` wrapping `self`.
    func prepare<Response>(preprocessor: Fetcher<Self, Response>.Preprocessor? = nil,
                           processor: @escaping Fetcher<Self, Response>.Processor,
                           pager: @escaping Fetcher<Self, Response>.Pager) -> Fetcher<Self, Response>.Paginated {
        return .init(request: self,
                     preprocessor: preprocessor,
                     processor: processor,
                     pager: pager)
    }
    
    /// Returns a `Fetcher.Paginated`, returning a valid JSON.
    /// - parameters:
    ///     - type: A `DynamicResponse` metatype.
    ///     - preprocessor: An optional `Preprocessor`.
    ///     - pager: A valid `Pager`.
    /// - returns: A `Fetcher.Paginated` wrapping `self`.
    func prepare<Response: DynamicResponse & Decodable>(_ type: Response.Type,
                                                        preprocessor: Fetcher<Self, Response>.Preprocessor? = nil,
                                                        pager: @escaping Fetcher<Self, Response>.Pager) -> Fetcher<Self, Response>.Paginated {
        return prepare(preprocessor: preprocessor,
                       processor: { $0.flatMap { data in Result { try JSONDecoder().decode(Response.self, from: data) }}},
                       pager: pager)
    }

    /// Returns a `Fetcher.Paginated`, returning a valid JSON.
    /// - parameters:
    ///     - preprocessor: An optional `Preprocessor`.
    ///     - pager: A valid `Pager`.
    /// - returns: A `Fetcher.Paginated` wrapping `self`.
    func prepare(preprocessor: Fetcher<Self, Response>.Preprocessor? = nil,
                 pager: @escaping Fetcher<Self, Response>.Pager) -> Fetcher<Self, Response>.Paginated {
        return prepare(Response.self,
                       preprocessor: preprocessor,
                       pager: pager)
    }
    
    /// Returns a `Fetcher.Disposable`.
    /// - parameters:
    ///     - preprocessor: An optional `Preprocessor`.
    ///     - processor: A valid `Processor`.
    /// - returns: A `Fetcher.Disposable` wrapping `self`.
    func prepare<Response>(preprocessor: Fetcher<Self, Response>.Preprocessor? = nil,
                           processor: @escaping Fetcher<Self, Response>.Processor) -> Fetcher<Self, Response>.Disposable {
        return .init(request: self,
                     preprocessor: preprocessor,
                     processor: processor)
    }
    
    /// Returns a `Fetcher.Disposable`.
    /// - parameters:
    ///     - type: A `DynamicResponse` metatype.
    ///     - preprocessor: An optional `Preprocessor`.
    /// - returns: A `Fetcher.Disposable` wrapping `self`.
    func prepare<Response: DynamicResponse & Decodable>(_ type: Response.Type,
                                                        preprocessor: Fetcher<Self, Response>.Preprocessor? = nil) -> Fetcher<Self, Response>.Disposable {
        return prepare(preprocessor: preprocessor,
                       processor: { $0.flatMap { data in Result { try JSONDecoder().decode(Response.self, from: data) }}})
    }

    
    /// Returns a `Fetcher.Disposable`, returning a valid JSON.
    /// - parameter preprocessor: An optional `Preprocessor`.
    /// - returns: A `Fetcher.Disposable` wrapping `self`.
    func prepare(preprocessor: Fetcher<Self, Response>.Preprocessor? = nil) -> Fetcher<Self, Response>.Disposable {
        return prepare(Response.self, preprocessor: preprocessor)
    }
}