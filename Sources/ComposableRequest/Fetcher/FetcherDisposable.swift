//
//  FetcherDisposable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

public extension Fetcher {
    /// A `struct` holding reference to a `DisposableFetchable`.
    struct Disposable: Lockable {
        /// A `struct` holding reference to a switching `Disposable`.
        internal struct Switcher {
            /// The actual `Disposable` maker.
            var constructor: (Result<Response, Error>) -> Request?
            /// Whether it should inherit the parent preprocessors or not. Defaults to `true`.
            var shouldInheritParentPreprocessor: Bool = true
        }

        /// The request.
        public private(set) var request: Request
        /// The pre-processor.
        public private(set) var preprocessor: Preprocessor?
        /// The processor.
        internal private(set) var processor: Processor

        /// The request to switch to on completion.
        internal private(set) var switchers: [Switcher] = []

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

        /// Switch the `Fetcher.Disposable` after receiving a response and return only once.
        /// Can be concatened.
        ///
        /// ```swift
        /// // This will only return the response for the third request.
        /// fetchable.switch { _ in /* second request */ }.switch { _ in /* third request */ }
        /// ```
        ///
        /// - parameters:
        ///     - fetchable: A block returning an optional instance of `Request`
        ///     - shouldInheritProcessor: Whether `self` processors should be added to the new `fetchable`. Defaults to `true`.
        public func `switch`(to fetchable: @escaping (Result<Response, Error>) -> Request?,
                             inheritingProcessor shouldInheritProcessor: Bool = true) -> Disposable {
            return copy(self) {
                $0.switchers.append(.init(constructor: fetchable, shouldInheritParentPreprocessor: shouldInheritProcessor))
            }
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
        var switcherOffset = 0
        // Return the task.
        return Requester.Task(request: preprocessor?(request) ?? request, requester: requester) {
            // Get the next `Endpoint`.
            let mapped = self.processor($1.value)
            // Notify completion.
            guard switcherOffset < self.switchers.count else {
                requester.configuration.dispatcher.response.handle { onComplete(mapped) }
                return (nil, shouldResume: false)
            }
            // Switch to `switcher`.
            let switcher = self.switchers[switcherOffset]
            guard let request = switcher.constructor(mapped) else {
                requester.configuration.dispatcher.response.handle { onComplete(mapped) }
                return (nil, shouldResume: false)
            }
            // Update values and fetch.
            switcherOffset += 1
            return (switcher.shouldInheritParentPreprocessor
                        ? (self.preprocessor?(request) ?? request)
                        : request,
                    shouldResume: true)
        }
    }

    /// Prepare a `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`.
    ///     - onComplete: A block called with the `Response`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    public func debugTask(by requester: Requester,
                          onComplete: @escaping (Requester.Task.Response<Response>) -> Void) -> Requester.Task {
        var switcherOffset = 0
        // Return the task.
        return Requester.Task(request: preprocessor?(request) ?? request, requester: requester) {
            // Get the next `Endpoint`.
            let mapped = Requester.Task.Response<Response>(value: self.processor($1.value), response: $1.response)
            // Notify completion.
            guard switcherOffset < self.switchers.count else {
                requester.configuration.dispatcher.response.handle { onComplete(mapped) }
                return (nil, shouldResume: false)
            }
            // Switch to `switcher`.
            let switcher = self.switchers[switcherOffset]
            guard let request = switcher.constructor(mapped.value) else {
                requester.configuration.dispatcher.response.handle { onComplete(mapped) }
                return (nil, shouldResume: false)
            }
            // Update values and fetch.
            switcherOffset += 1
            return (switcher.shouldInheritParentPreprocessor
                        ? (self.preprocessor?(request) ?? request)
                        : request,
                    shouldResume: true)
        }
    }
}
