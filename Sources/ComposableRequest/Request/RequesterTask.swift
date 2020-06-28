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

            /// Map `value` to a new one.
            public func map<NewValue>(_ handler: (Value) throws -> NewValue) -> Response<NewValue> {
                return .init(value: value.flatMap { value in Result { try handler(value) }},
                             response: response)
            }
        }

        /// An `enum` holding reference to the current `Task` state.
        public enum State: Hashable {
            /// The task has not been resumed yet.
            case initiated
            /// The task is currently being serviced by the requester.
            case running
            /// The task has received a `cancel` message.
            case canceling
            /// The task has completed (without being cancelled).
            case completed
        }

        /// A valid identifier.
        internal let identifier: UUID = .init()
        /// The current state.
        public private(set) var state: State

        /// The current request.
        public private(set) var current: Requestable?
        /// The next request.
        public private(set) var next: Requestable?

        /// A weak reference to a `Requester`. Defaults to `.default`.
        public private(set) weak var requester: Requester?
        /// A valid `URLSessionDataTask` for the current request.
        internal var sessionTask: URLSessionDataTask?
        /// A block to fetch the next request and whether it should be resumed or not.
        internal let paginator: (Requestable?, Response<Data>) -> (Requestable?, shouldResume: Bool)

        /// The logger level. Defaults to `Logger.level`.
        public var loggerLevel: Logger.Level = Logger.level

        // MARK: Lifecycle
        /// Init.
        /// - parameters:
        ///     - request: A concrete instance conforming to `Requestable`.
        ///     - requester: A valid, strongly referenced, `Requester`. Defaults to `.default`.
        ///     - loggerLevel: A valid `Logger.Level`. Defaults to `Logger.level`.
        ///     - paginator: A block turning a `Response` into an optional `Composable` and `Requestable`.
        internal init(request: Requestable,
                      requester: Requester = .default,
                      loggerLevel: Logger.Level = Logger.level,
                      paginator: @escaping (Requestable?, Response<Data>) -> (Requestable?, shouldResume: Bool)) {
            self.next = request
            self.requester = requester
            self.paginator = paginator
            self.loggerLevel = loggerLevel
            self.state = .initiated
        }

        // MARK: State
        /// Update logging level.
        /// - parameter logginLevel: An optional `Logger.Level`. Defaults to `nil`, i.e. `Logger.level`.
        public func logging(level: Logger.Level? = nil) -> Requester.Task {
            self.loggerLevel = level ?? Logger.level
            return self
        }
        
        /// Cancel the ongoing request and all future ones.
        /// Calling `resume` on a cancelled `Task` makes it start agaain.
        public func cancel() {
            requester?.configuration.dispatcher.request.handle { [weak self] in
                guard let self = self else { return }
                // Update state.
                self.state = .canceling
                self.sessionTask?.cancel()
                self.sessionTask = nil
                // Adjust requests.
                self.next = self.current ?? self.next
                self.current = nil
            }
        }

        /// Complete the ongoing request.
        /// - parameter request: The next request.
        internal func complete(with request: Requestable?) {
            guard state != .canceling else { self.requester?.cancel(self); return }
            // Update state.
            state = .completed
            sessionTask?.cancel()
            sessionTask = nil
            // Adjust requests.
            next = request
            current = nil
            // Remove from `requester`.
            if request == nil { self.requester?.cancel(self) }
        }

        /// Fetch the next request.
        /// - returns: `self` if there are no active tasks, the request was valid and `requester` still in memory, `nil` otherwise.
        @discardableResult
        public func resume() -> Task? {
            // Check for a valid status.
            guard sessionTask == nil,
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
                    let (next, shouldResume) = self.paginator(self.current, .init(value: .failure(Error.invalidEndpoint)))
                    self.complete(with: next)
                    if shouldResume && self.state != .canceling { configuration.dispatcher.request.handle { self.resume() }}
                }
                return
            }
            // Log current request.
            loggerLevel.log(request: request)
            // Set `task`.
            configuration.dispatcher.request.handle(waiting: configuration.waiting) {
                self.sessionTask = session.dataTask(with: request) { [weak self] data, response, error in
                    // Process.
                    guard let self = self else { return }
                    self.loggerLevel.log(response: response as? HTTPURLResponse, error: error)
                    configuration.dispatcher.process.handle {
                        // Prepare next.
                        var next: Requestable?
                        var shouldResume = false
                        // Switch response.
                        if let error = error {
                            (next, shouldResume) = self.paginator(self.current, .init(value: .failure(error)))
                        } else if let data = data {
                            (next, shouldResume) = self.paginator(self.current, .init(value: .success(data),
                                                                                 response: response as? HTTPURLResponse))
                        } else {
                            (next, shouldResume) = self.paginator(self.current, .init(value: .failure(Error.invalidData)))
                        }
                        self.complete(with: next)
                        if shouldResume && self.state != .canceling { configuration.dispatcher.request.handle { self.resume() }}
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
