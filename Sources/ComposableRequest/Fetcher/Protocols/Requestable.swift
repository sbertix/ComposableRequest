//
//  Requestable.swift
//  ComposableReuqest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// A `protocol` defining the initializer of a `Requester.Task`.
public protocol Requestable {
    /// An associated `Request`.
    associatedtype Request: Fetchable
    /// An associated `Response`.
    associatedtype Response
}

/// A `protocol` defining a paginated `Requestable`.
public protocol PaginatedRequestable: Requestable {
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - maxLength: The maximum amount of pages that should be returned. Pass `.max` to keep fetching until no next requet is found.
    ///     - requester: A valid `Requester`.
    ///     - onComplete: An optional block called when `maxLength` is reached or no next endpoint is provided.
    ///     - onChange: A block called everytime a new page is fetched.
    /// - returns: A `Requester.Task`. You need to `resume` it for it to start.
    func task(maxLength: Int,
              by requester: Requester,
              onComplete: ((_ length: Int) -> Void)?,
              onChange: @escaping (Result<Response, Error>) -> Void) -> Requester.Task
    
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - maxLength: The maximum amount of pages that should be returned. Pass `.max` to keep fetching until no next requet is found.
    ///     - requester: A valid `Requester`.
    ///     - onComplete: An optional block called when `maxLength` is reached or no next endpoint is provided.
    ///     - onChange: A block called everytime a new page is fetched.
    /// - returns: A `Requester.Task`. You need to `resume` it for it to start.
    func debugTask(maxLength: Int,
                   by requester: Requester,
                   onComplete: ((Int) -> Void)?,
                   onChange: @escaping (Requester.Task.Response<Response>) -> Void) -> Requester.Task
}

public extension PaginatedRequestable {
    /// Hide the `Requetable` concrete type, making it read-only.
    /// - returns: A `ReadonlyFetcher` wrapping `self`.
    func fixed() -> ReadonlyFetcher<Self> { return .init(request: self) }
    
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - maxLength: The maximum amount of pages that should be returned. Pass `.max` to keep fetching until no next requet is found.
    ///     - requester: A valid `Requester`.
    ///     - onComplete: An optional block called when `maxLength` is reached or no next endpoint is provided.
    ///     - onChange: A block called everytime a new page is fetched.
    /// - returns: A `Requester.Task`. You need to `resume` it for it to start.
    func task(maxLength: Int,
              by requester: Requester = .default,
              onComplete: ((_ length: Int) -> Void)? = nil,
              onChange: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return task(maxLength: maxLength, by: requester, onComplete: onComplete, onChange: onChange)
    }

    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - maxLength: The maximum amount of pages that should be returned. Pass `.max` to keep fetching until no next requet is found.
    ///     - requester: A valid `Requester`.
    ///     - onComplete: An optional block called when `maxLength` is reached or no next endpoint is provided.
    ///     - onChange: A block called everytime a new page is fetched.
    /// - returns: A `Requester.Task`. You need to `resume` it for it to start.
    func debugTask(maxLength: Int,
                   by requester: Requester = .default,
                   onComplete: ((Int) -> Void)? = nil,
                   onChange: @escaping (Requester.Task.Response<Response>) -> Void) -> Requester.Task {
        return debugTask(maxLength: maxLength, by: requester, onComplete: onComplete, onChange: onChange)
    }
}

/// A `protocol` defining a disposable `Requestable`.
public protocol DisposableRequestable: Requestable {
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

extension DisposableRequestable {
    /// Hide the `Requetable` concrete type, making it read-only.
    /// - returns: A `ReadonlyDisposableFetcher` wrapping `self`.
    func fixed() -> ReadonlyDisposableFetcher<Self> { return .init(request: self) }

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
