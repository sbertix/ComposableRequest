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
    ///     - max: The maximum amount of time we should keep calling `next`. Defaults to `.max`. Must be bigger than `0`.
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onComplete: A block called when `maxLength` is reached or no next endpoint is provided, passing how many pages it fetched.
    ///     - onChange: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func cycleTask(maxLength: Int = .max,
                   by requester: Requester = .default,
                   onComplete: ((Int) -> Void)? = nil,
                   onChange: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        precondition(maxLength > 0, "`cycleTask` requires a positive `max` value")
        var count = 0
        return Requester.Task(endpoint: self.query(self.key, value: self.initial),
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $0.map { Response.process(data: $0.data) }
                                var nextEndpoint: Self?
                                if let nextValue = self.next(mapped) {
                                    nextEndpoint = self.query(self.key, value: nextValue)
                                        .header(self.nextHeader?(mapped) ?? [:])
                                        .body(self.nextBody?(mapped) ?? [:])
                                }
                                // Notify completion.
                                count += 1
                                requester.configuration.responseQueue.handle {
                                    onChange(mapped)
                                    if count >= maxLength || nextEndpoint == nil { onComplete?(count) }
                                }
                                // Return the new endpoint.
                                return count < maxLength ? nextEndpoint : nil
        }
    }

    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - max: The maximum amount of time we should keep calling `next`. Defaults to `.max`. Must be bigger than `0`.
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onComplete: A block called when `maxLength` is reached or no next endpoint is provided, passing how many pages it fetched.
    ///     - onChange: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func debugCycleTask(maxLength: Int = .max,
                        by requester: Requester = .default,
                        onComplete: ((Int) -> Void)? = nil,
                        onChange: @escaping (Requester.Task.Result<Response>) -> Void) -> Requester.Task {
        precondition(maxLength > 0, "`cycleTask` requires a positive `max` value")
        var count = 0
        return Requester.Task(endpoint: self.query(self.key, value: self.initial),
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $0.map { (data: Response.process(data: $0.data), response: $0.response) }
                                var nextEndpoint: Self?
                                if let nextValue = self.next(mapped.map { $0.data }) {
                                    nextEndpoint = self.query(self.key, value: nextValue)
                                        .header(self.nextHeader?(mapped.map { $0.data }))
                                        .body(self.nextBody?(mapped.map { $0.data }))
                                }
                                // Notify completion.
                                count += 1
                                requester.configuration.responseQueue.handle {
                                    onChange(mapped)
                                    if count >= maxLength || nextEndpoint == nil { onComplete?(count) }
                                }
                                // Return the new endpoint.
                                return count < maxLength ? nextEndpoint : nil
        }
    }
}

/// Default extensions for a `Singular` `Requestable`.
public extension Requestable where Self: Singular, Self: Composable {
    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onCompleted: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func task(by requester: Requester = .default,
              onCompleted: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return Requester.Task(endpoint: self,
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $0.map { Response.process(data: $0.data) }
                                // Notify completion.
                                requester.configuration.responseQueue.handle { onCompleted(mapped) }
                                return nil
        }
    }

    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onCompleted: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func debugTask(by requester: Requester = .default,
                   onCompleted: @escaping (Requester.Task.Result<Response>) -> Void) -> Requester.Task {
        return Requester.Task(endpoint: self,
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $0.map { (data: Response.process(data: $0.data), response: $0.response) }
                                // Notify completion.
                                requester.configuration.responseQueue.handle { onCompleted(mapped) }
                                return nil
        }
    }
}
