//
//  DisposableFetcher.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// A `struct` holding reference to a `DisposableManifest`.
public struct DisposableFetcher<Request: Fetchable, Response>: DisposableManifest, Lockable {
    /// The `Request`.
    public private(set) var request: Request
    /// The mapper.
    public private(set) var map: Fetcher<Request, Response>.Map

    /// Init.
    /// - parameters:
    ///     - request: A valid `Request`.
    ///     - map: A valid mapper.
    internal init(request: Request,
                  map: @escaping Fetcher<Request, Response>.Map) {
        self.request = request
        self.map = map
        precondition(self.continue(from: request, processing: nil) == nil)
    }
}

extension DisposableFetcher: DisposableRequestable {
    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`.
    ///     - onComplete: A block called with the `Response`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    public func task(by requester: Requester,
                     onComplete: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return Requester.Task(request: request, requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $1.value.flatMap { data in Result { try self.map(data) }}
                                // Notify completion.
                                requester.configuration.dispatcher.response.handle { onComplete(mapped) }
                                return (nil, shouldResume: false)
        }
    }

    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`.
    ///     - onComplete: A block called with the `Response`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    public func debugTask(by requester: Requester,
                          onComplete: @escaping (Requester.Task.Response<Response>) -> Void) -> Requester.Task {
        return Requester.Task(request: request, requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = Requester.Task.Response<Response>(value: $1.value.flatMap { data in Result { try self.map(data) }},
                                                                                        response: $1.response)
                                // Notify completion.
                                requester.configuration.dispatcher.response.handle { onComplete(mapped) }
                                return (nil, shouldResume: false)
        }
    }
}

extension DisposableFetcher: WrappedBodyComposable, BodyComposable where Request: BodyComposable {
    public var bodyComposable: Request { get { return request } set { request = newValue }}
}
extension DisposableFetcher: WrappedHeaderComposable, HeaderComposable where Request: HeaderComposable {
    public var headerComposable: Request { get { return request } set { request = newValue }}
}
extension DisposableFetcher: WrappedMethodComposable, MethodComposable where Request: MethodComposable {
    public var methodComposable: Request { get { return request } set { request = newValue }}
}
extension DisposableFetcher: WrappedPathComposable, PathComposable where Request: PathComposable {
    public var pathComposable: Request { get { return request } set { request = newValue }}
}
extension DisposableFetcher: WrappedQueryComposable, QueryComposable where Request: QueryComposable {
    public var queryComposable: Request { get { return request } set { request = newValue }}
}
