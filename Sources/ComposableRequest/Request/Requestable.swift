//
//  Requestable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `protocol` describing a valid `Request`.
public protocol Requestable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    func request() -> URLRequest?
}

/// Default extensions for a `Paginatable` `Requestable`.
public extension Requestable where Self: Paginatable, Self: Composable {
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - maxLength: The maximum amount of pages that should be returned. Pass `.max` to keep fetching until no next requet is found.
    ///     - requester: A valid `Requester`. Defaults to `.default`.
    ///     - onComplete: An optional block called when `maxLength` is reached or no next endpoint is provided.
    ///     - onChange: A block called everytime a new page is fetched.
    /// - returns: A `Requester.Task`. You need to `resume` it for it to start.
    func task(maxLength: Int,
              by requester: Requester = .default,
              onComplete: ((_ length: Int) -> Void)? = nil,
              onChange: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        precondition(maxLength > 0, "`cycleTask` requires a positive `maxLength` value")
        var count = 0
        return Requester.Task(request: self.query(self.key, value: self.initial),
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $0.value.map(Response.process)
                                var nextEndpoint: Self?
                                if let nextValue = self.next(mapped) {
                                    nextEndpoint = self.query(self.key, value: nextValue)
                                        .header(self.nextHeader?(mapped) ?? [:])
                                        .body(self.nextBody?(mapped) ?? [:])
                                }
                                // Notify completion.
                                count += 1
                                requester.configuration.dispatcher.response.handle {
                                    onChange(mapped)
                                    if count >= maxLength || nextEndpoint == nil { onComplete?(count) }
                                }
                                // Return the new endpoint.
                                return (nextEndpoint, shouldResume: count < maxLength)
        }
    }

    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - maxLength: The maximum amount of pages that should be returned. Pass `.max` to keep fetching until no next requet is found.
    ///     - requester: A valid `Requester`. Defaults to `.default`.
    ///     - onComplete: An optional block called when `maxLength` is reached or no next endpoint is provided.
    ///     - onChange: A block called everytime a new page is fetched.
    /// - returns: A `Requester.Task`. You need to `resume` it for it to start.
    func debugTask(maxLength: Int,
                   by requester: Requester = .default,
                   onComplete: ((Int) -> Void)? = nil,
                   onChange: @escaping (Requester.Task.Response<Response>) -> Void) -> Requester.Task {
        precondition(maxLength > 0, "`cycleTask` requires a positive `maxLength` value")
        var count = 0
        return Requester.Task(request: self.query(self.key, value: self.initial),
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = Requester.Task.Response<Response>(value: $0.value.map(Response.process), response: $0.response)
                                var nextEndpoint: Self?
                                if let nextValue = self.next(mapped.value) {
                                    nextEndpoint = self.query(self.key, value: nextValue)
                                        .header(self.nextHeader?(mapped.value))
                                        .body(self.nextBody?(mapped.value))
                                }
                                // Notify completion.
                                count += 1
                                requester.configuration.dispatcher.response.handle {
                                    onChange(mapped)
                                    if count >= maxLength || nextEndpoint == nil { onComplete?(count) }
                                }
                                // Return the new endpoint.
                                return (nextEndpoint, shouldResume: count < maxLength)
        }
    }
}

/// Default extensions for a `Singular` `Requestable`.
public extension Requestable where Self: Singular, Self: Composable {
    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onComplete: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func task(by requester: Requester = .default,
              onComplete: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return Requester.Task(request: self,
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $0.value.map(Response.process)
                                // Notify completion.
                                requester.configuration.dispatcher.response.handle { onComplete(mapped) }
                                return (nil, shouldResume: false)
        }
    }

    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onComplete: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func debugTask(by requester: Requester = .default,
                   onComplete: @escaping (Requester.Task.Response<Response>) -> Void) -> Requester.Task {
        return Requester.Task(request: self,
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = Requester.Task.Response<Response>(value: $0.value.map(Response.process), response: $0.response)
                                // Notify completion.
                                requester.configuration.dispatcher.response.handle { onComplete(mapped) }
                                return (nil, shouldResume: false)
        }
    }
}
