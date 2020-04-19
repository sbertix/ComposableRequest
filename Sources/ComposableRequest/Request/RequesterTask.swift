//
//  RequesterTask.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/04/2020.
//

import Foundation

public extension Requester {
    /// A `class` holding reference to a pausable and cancellable `Request`.
    final class Task: Hashable {
        /// A `struct` holding reference to a valid `Response`.
        public struct Response<Value> {
            /// Some throwable `Value`.
            public let value: Result<Value, Swift.Error>
            /// A valid optional `HTTPURLResponse`.
            public let response: HTTPURLResponse?
            
            /// Init.
            internal init(value: Result<Value, Swift.Error>, response: HTTPURLResponse? = nil) {
                self.value = value
                self.response = response
            }
        }
        
        /// An `enum` holding reference to the current `Task` state.
        public enum State: Hashable {
            /// The task is currently being serviced by the requester.
            case running
            /// The task was suspended.
            case suspended
            /// The task has received a `cancel` message.
            case canceling
            /// The task has completed (without being cancelled).
            case completed
        }
        
        /// A valid identifier.
        public let identifier: UUID = .init()
        /// The current state.
        public private(set) var state: State
        
        /// The current request.
        public private(set) var current: (Composable & Requestable)?
        /// The next request.
        public private(set) var next: (Composable & Requestable)?
        
        /// A weak reference to a `Requester`. Defaults to `.default`.
        public weak var requester: Requester?
        /// A valid `URLSessionDataTask` for the current request.
        internal var sessionTask: URLSessionDataTask?
        /// A block to fetch the next request and whether it should be resumed or not.
        internal let paginator: (Response<Data>) -> ((Composable & Requestable)?, shouldResume: Bool)
        
        // MARK: Lifecycle
        /// Init.
        /// - parameters:
        ///     - request: A concrete instance conforming to `Composable` and `Requestable`.
        ///     - requester: A valid, strongly referenced, `Requester`. Defaults to `.default`.
        ///     - paginator: A block turning a `Response` into an optional `Composable` and `Requestable`.
        internal init(request: Composable & Requestable,
                      requester: Requester = .default,
                      paginator: @escaping (Response<Data>) -> ((Composable & Requestable)?, shouldResume: Bool)) {
            self.next = request
            self.requester = requester
            self.paginator = paginator
            self.state = .suspended
        }
        
        // MARK: State
        /// Cancel the ongoing request and all future ones.
        /// Calling `resume` on a cancelled `Task` does nothing.
        public func cancel() {
            // Remove from `requester`.
            requester?.cancel(self)
            // Update state.
            state = .canceling
            sessionTask?.cancel()
            sessionTask = nil
            // Adjust requests.
            next = current
            current = nil
        }
        
        /// Suspend the ongoing request.
        /// Calling `resume` on a suspended `Task` resumes it.
        public func suspend() {
            state = .suspended
            sessionTask?.suspend()
        }
        
        /// Complete the ongoing request.
        /// - parameter request: The next request.
        internal func complete(with request: (Composable & Requestable)?) {
            // Remove from `requester`.
            requester?.cancel(self)
            // Update state.
            state = .completed
            sessionTask?.cancel()
            sessionTask = nil
            // Adjust requests.
            next = request
            current = nil
        }
        
        /// Fetch the next request.
        /// - returns: `self` if there are no active tasks, the request was valid and `requester` still in memory, `nil` otherwise.
        @discardableResult
        public func resume() -> Task? {
            // Check for suspended.
            if state == .suspended, sessionTask?.state == .suspended {
                sessionTask?.resume()
                return self
            }
            // Check for a valid status.
            guard state != .canceling,
                sessionTask == nil,
                next?.request() != nil,
                let requester = requester else {
                    return nil
            }
            /// Add to the `requester`.
            state = .running
            current = next
            next = nil
            requester.schedule(self)
            return self
        }
        
        /// Fetch using a given `session`.
        /// - parameters:
        ///     - session: A `URLSession`.
        ///     -  configuration: A `Requester.Configuration`.
        internal func fetch(using session: URLSession,
                            configuration: Requester.Configuration) {
            // Check for a valid `URL`.
            guard let request = current?.request() else {
                configuration.dispatcher.process.handle { [weak self] in
                    guard let self = self else { return }
                    // Complete and load next.
                    let (next, shouldResume) = self.paginator(.init(value: .failure(Error.invalidEndpoint)))
                    self.complete(with: next)
                    if shouldResume { configuration.dispatcher.request.handle { self.resume() }}
                }
                return
            }
            // Set `task`.
            configuration.dispatcher.request.handle(waiting: configuration.waiting) {
                self.sessionTask = session.dataTask(with: request) { [weak self] data, response, error in
                    guard let self = self else { return }
                    configuration.dispatcher.process.handle {
                        // Prepare next.
                        var next: (Composable & Requestable)?
                        var shouldResume = false
                        // Switch response.
                        if let error = error {
                            (next, shouldResume) = self.paginator(.init(value: .failure(error)))
                        } else if let data = data {
                            (next, shouldResume) = self.paginator(.init(value: .success(data), response: response as? HTTPURLResponse))
                        } else {
                            (next, shouldResume) = self.paginator(.init(value: .failure(Error.invalidData)))
                        }
                        self.complete(with: next)
                        if shouldResume { configuration.dispatcher.request.handle { self.resume() }}
                    }
                }
                self.sessionTask?.resume()
            }
        }
        
        // MARK: Hashable
        /// Conform to hashable.
        public func hash(into hasher: inout Hasher) { hasher.combine(identifier) }
        
        /// Conform to equatable.
        public static func ==(lhs: Task, rhs: Task) -> Bool { return lhs.identifier == rhs.identifier }
    }
}
