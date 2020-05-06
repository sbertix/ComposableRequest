//
//  PaginatedFetchable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Foundation

/// A `protocol` defining a paginated `Requestable`.
public protocol PaginatedFetchable: Fetchable {
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

public extension PaginatedFetchable {
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
