//
//  ReadonlyFetcher.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Foundation

/// A `struct` holding reference to a `Fetcher`.
public struct ReadonlyFetcher<Requestable: PaginatedRequestable>: PaginatedRequestable {
    /// The associated request.
    public typealias Request = Requestable.Request
    /// The associated response.
    public typealias Response = Requestable.Response
    
    /// The request.
    internal var request: Requestable
    
    /// Init.
    /// - parameter request: A valid `Requestable`.
    internal init(request: Requestable) { self.request = request }
    
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - maxLength: The maximum amount of pages that should be returned. Pass `.max` to keep fetching until no next requet is found.
    ///     - requester: A valid `Requester`. Defaults to `.default`.
    ///     - onComplete: An optional block called when `maxLength` is reached or no next endpoint is provided.
    ///     - onChange: A block called everytime a new page is fetched.
    /// - returns: A `Requester.Task`. You need to `resume` it for it to start.
    public func task(maxLength: Int,
                     by requester: Requester,
                     onComplete: ((_ length: Int) -> Void)?,
                     onChange: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return request.task(maxLength: maxLength,
                            by: requester,
                            onComplete: onComplete,
                            onChange: onChange)
    }
    
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - maxLength: The maximum amount of pages that should be returned. Pass `.max` to keep fetching until no next requet is found.
    ///     - requester: A valid `Requester`. Defaults to `.default`.
    ///     - onComplete: An optional block called when `maxLength` is reached or no next endpoint is provided.
    ///     - onChange: A block called everytime a new page is fetched.
    /// - returns: A `Requester.Task`. You need to `resume` it for it to start.
    public func debugTask(maxLength: Int,
                          by requester: Requester,
                          onComplete: ((Int) -> Void)?,
                          onChange: @escaping (Requester.Task.Response<Response>) -> Void) -> Requester.Task {
        return request.debugTask(maxLength: maxLength,
                                 by: requester,
                                 onComplete: onComplete,
                                 onChange: onChange)
    }
}

extension ReadonlyFetcher: Lockable where Requestable: Lockable { }
