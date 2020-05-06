//
//  Fetcher.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// A `struct` holding reference to a `Manifest`.
public struct Fetcher<Request: Fetchable, Response>: Manifest, Lockable {
    /// A `typealias` for a `block` associating some `Data` to a `Response`.
    public typealias Map = (_ data: Data) throws -> Response
    /// A `typealias` for a `block` associating a new `Request` from the current one and an optional `Response`.
    public typealias Next = (_ request: Request, _ result: Result<Response, Error>?) -> Request?

    /// The initial `Request`.
    internal var request: Request
    /// The mapper.
    internal var map: Map
    /// The transformation.
    internal var next: Next?
    
    /// Init.
    /// - parameters:
    ///     - request: A valid `Request`.
    ///     - map: A valid mapper.
    ///     - next: A valid transformation.
    internal init(request: Request,
                  map: @escaping Map,
                  next: Next?) {
        self.request = request
        self.map = map
        self.next = next
    }
    
    /// Compute the next `Request`, from the current one and a possible response.
    /// - parameters:
    ///     - request: The last valid `Request`.
    ///     - result: An optional `Result` for the last valid `Response`. Defaults to `nil`.
    /// - returns: `nil` if no next `Request` should be returned, the next `Request` otherwise.
    public func `continue`(from request: Request, processing result: Result<Response, Error>?) -> Request? {
        return  next?(request, result)
    }
}

extension Fetcher: PaginatedRequestable {
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
        precondition(maxLength > 0, "`task` requires a positive `maxLength` value")
        var count = 0
        return Requester.Task(request: self.continue(from: request, processing: nil) ?? self.request,
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $1.value.flatMap { data in Result { try self.map(data) }}
                                let next = $0.flatMap { $0 as? Request }.flatMap { self.continue(from: $0, processing: mapped) }
                                // Notify completion.
                                count += 1
                                requester.configuration.dispatcher.response.handle {
                                    onChange(mapped)
                                    if count >= maxLength || next == nil { onComplete?(count) }
                                }
                                // Return the new endpoint.
                                return (next, shouldResume: count < maxLength)
        }
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
        precondition(maxLength > 0, "`debugTask` requires a positive `maxLength` value")
        var count = 0
        return Requester.Task(request: self.continue(from: request, processing: nil) ?? self.request,
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = Requester.Task.Response<Response>(value: $1.value.flatMap { data in Result { try self.map(data) }},
                                                                                        response: $1.response)
                                let next = $0.flatMap { $0 as? Request }.flatMap { self.continue(from: $0, processing: mapped.value) }
                                // Notify completion.
                                count += 1
                                requester.configuration.dispatcher.response.handle {
                                    onChange(mapped)
                                    if count >= maxLength || next == nil { onComplete?(count) }
                                }
                                // Return the new endpoint.
                                return (next, shouldResume: count < maxLength)
        }
    }
}

extension Fetcher: WrappedBodyComposable, BodyComposable where Request: BodyComposable {
    public var bodyComposable: Request { get { return request } set { request = newValue }}
}
extension Fetcher: WrappedHeaderComposable, HeaderComposable where Request: HeaderComposable {
    public var headerComposable: Request { get { return request } set { request = newValue }}
}
extension Fetcher: WrappedMethodComposable, MethodComposable where Request: MethodComposable {
    public var methodComposable: Request { get { return request } set { request = newValue }}
}
extension Fetcher: WrappedPathComposable, PathComposable where Request: PathComposable {
    public var pathComposable: Request { get { return request } set { request = newValue }}
}
extension Fetcher: WrappedQueryComposable, QueryComposable where Request: QueryComposable {
    public var queryComposable: Request { get { return request } set { request = newValue }}
}
