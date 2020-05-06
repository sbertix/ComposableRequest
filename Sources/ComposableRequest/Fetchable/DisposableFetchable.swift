//
//  DisposableRequest.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Foundation

/// A `protocol` defining a disposable `Requestable`.
public protocol DisposableFetchable: Fetchable {
    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`.
    ///     - onComplete: A block called with the `Response`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func task(by requester: Requester,
              onComplete: @escaping (Result<Response, Error>) -> Void) -> Requester.Task
    
    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`.
    ///     - onComplete: A block called with the `Response`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func debugTask(by requester: Requester,
                   onComplete: @escaping (Requester.Task.Response<Response>) -> Void) -> Requester.Task
}

extension DisposableFetchable {
    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`.
    ///     - onComplete: A block called with the `Response`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func task(requester: Requester = .default, onComplete: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return task(by: requester, onComplete: onComplete)
    }
    
    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`.
    ///     - onComplete: A block called with the `Response`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func debugTask(requester: Requester = .default,
                   onComplete: @escaping (Requester.Task.Response<Response>) -> Void) -> Requester.Task {
        return debugTask(by: requester, onComplete: onComplete)
    }
}
