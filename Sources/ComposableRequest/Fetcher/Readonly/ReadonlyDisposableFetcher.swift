//
//  ReadonlyDisposableFetcher.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Foundation

/// A `struct` holding reference to a `Fetcher`.
public struct ReadonlyDisposableFetcher<Requestable: DisposableRequestable>: DisposableRequestable {
    /// The associated request.
    public typealias Request = Requestable.Request
    /// The associated response.
    public typealias Response = Requestable.Response
    
    /// The request.
    internal var request: Requestable
    
    /// Init.
    /// - parameter request: A valid `Requestable`.
    internal init(request: Requestable) { self.request = request }
    
    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`.
    ///     - onComplete: A block called with the `Response`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    public func task(by requester: Requester,
                     onComplete: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return request.task(by: requester, onComplete: onComplete)
    }
    
    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`.
    ///     - onComplete: A block called with the `Response`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    public func debugTask(by requester: Requester,
                          onComplete: @escaping (Requester.Task.Response<Response>) -> Void) -> Requester.Task {
        return request.debugTask(by: requester, onComplete: onComplete)
    }
}

extension ReadonlyDisposableFetcher: Lockable where Requestable: Lockable { }
