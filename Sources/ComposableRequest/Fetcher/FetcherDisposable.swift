//
//  FetcherDisposable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

public extension Fetcher {
    /// A `struct` holding reference to a `DisposableFetchable`.
    struct Disposable: Preprocessable {
        /// The request.
        public private(set) var request: Request
        /// The pre-processor.
        public private(set) var preprocessor: Preprocessor?
        /// The processor.
        internal private(set) var processor: Processor

        /// Init.
        /// - parameters:
        ///     - request: A valid `Request`.
        ///     - preprocessor: An optional `Preprocessor`.
        ///     - processor: A valid `Processor`.
        internal init(request: Request,
                      preprocessor: Preprocessor? = nil,
                      processor: @escaping Processor) {
            self.request = request
            self.preprocessor = preprocessor
            self.processor = processor
        }

        /// Update `Preprocessor`.
        /// - parameter preprocessor: An optional `Preprocessor`.
        /// - returns: An instance of `Self`.
        public func replacing(preprocessor: Preprocessor?) -> Disposable {
            return copy(self) { $0.preprocessor = preprocessor }
        }
    }
}

extension Fetcher.Disposable: DisposableFetchable {
    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`.
    ///     - onComplete: A block called with the `Response`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    public func task(by requester: Requester,
                     onComplete: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return Requester.Task(request: preprocessor?(request) ?? request, requester: requester) {
            // Get the next `Endpoint`.
            let mapped = self.processor($1.value)
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
            let mapped = Requester.Task.Response<Response>(value: self.processor($1.value), response: $1.response)
            // Notify completion.
            requester.configuration.dispatcher.response.handle { onComplete(mapped) }
            return (nil, shouldResume: false)
        }
    }
}
