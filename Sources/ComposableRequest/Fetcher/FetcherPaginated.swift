//
//  FetcherPaginated.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

public extension Fetcher {
    /// A `struct` holding reference to a `PaginatedFetchable`.
    struct Paginated: Preprocessable {
        /// The request.
        public private(set) var request: Request
        /// The pre-processor.
        public private(set) var preprocessor: Preprocessor?
        /// The processor.
        internal private(set) var processor: Processor
        /// The pager.
        internal private(set) var pager: Pager
                
        /// Init.
        /// - parameters:
        ///     - request: A valid `Request`.
        ///     - preprocessor: An optional `Preprocessor`.
        ///     - processor: A valid `Processor`.
        internal init(request: Request,
                      preprocessor: Preprocessor? = nil,
                      processor: @escaping Processor,
                      pager: @escaping Pager) {
            self.request = request
            self.preprocessor = preprocessor
            self.processor = processor
            self.pager = pager
        }
        
        /// Update `Preprocessor`.
        /// - parameter preprocessor: An optional `Preprocessor`.
        /// - returns: An instance of `Self`.
        public func replacing(preprocessor: Preprocessor?) -> Paginated {
            return copy(self) { $0.preprocessor = preprocessor }
        }
    }
}

extension Fetcher.Paginated: PaginatedFetchable {
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
        guard let request = pager(preprocessor?(self.request) ?? self.request, nil) else {
            fatalError("`task` requires for the `pager` to return a valid initial request when `response == nil`.")
        }
        // Start cycling.
        var count = 0
        return Requester.Task(request:  request, requester: requester) {
            // Get the next `Endpoint`.
            let mapped = self.processor($1.value)
            let next = $0.flatMap { $0 as? Request }
                .flatMap { self.pager($0, mapped) }
                .flatMap { self.preprocessor?($0) ?? $0 }
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
        guard let request = pager(preprocessor?(self.request) ?? self.request, nil) else {
            fatalError("`debugTask` requires for the `pager` to return a valid initial request when `response == nil`.")
        }
        // Start cycling.
        var count = 0
        return Requester.Task(request:  request, requester: requester) {
            // Get the next `Endpoint`.
            let mapped = $1.map { try self.processor(.success($0)).get() }
            let next = $0.flatMap { $0 as? Request }
                .flatMap { self.pager($0, mapped.value) }
                .flatMap { self.preprocessor?($0) ?? $0 }
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
