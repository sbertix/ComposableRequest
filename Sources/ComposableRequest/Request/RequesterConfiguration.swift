//
//  RequesterConfiguration.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

public extension Requester {
    /// A `struct` defining a `Requester` settings.
    struct Configuration: Hashable {
        /// A `URLSessionConfiguration`.
        public private(set) var sessionConfiguration: URLSessionConfiguration

        /// The `Dispatcher`. Defaults to `.init()`.
        public private(set) var dispatcher: Dispatcher = .init()

        /// A range of `TimeInterval`s.
        /// A `randomElement()` in `waiting` will be spent waiting before every request.
        /// Defaults to `0.0...0.0`.
        public private(set) var waiting: ClosedRange<TimeInterval>

        // MARK: Lifecycle
        /// Init.
        /// - parameters:
        ///     - sessionConfiguration: A valid `URLSessionConfiguration`. Defaults to `.default`.
        ///     - dispatcher: A valid `Dispatcher`. Defaults to `.init()`.
        ///     - waiting: A `ClosedRange` of `TimeInterval`s. Defaults to `0.0...0.0`.
        public init(sessionConfiguration: URLSessionConfiguration = .default,
                    dispatcher: Dispatcher = .init(),
                    waiting: ClosedRange<TimeInterval> = 0...0) {
            self.sessionConfiguration = sessionConfiguration
            self.dispatcher = dispatcher
            self.waiting = waiting
        }

        // MARK: Transform
        /// Set the `sessionConfiguration`.
        /// - parameter sessionConfiguration: A valid `URLSessionConfiguration`.
        /// - returns: A modified copy of `self`.
        public func sessionConfiguration(_ sessionConfiguration: URLSessionConfiguration) -> Configuration {
            return copy(self) { $0.sessionConfiguration = sessionConfiguration }
        }

        /// Set the `dispatcher`.
        /// - parameter dispatcher: A valid `Dispatcher`.
        /// - returns: A modified copy of `self`.
        public func dispatcher(_ dispatcher: Dispatcher) -> Configuration {
            return copy(self) { $0.dispatcher = dispatcher }
        }

        /// Set the `waiting`.
        /// - parameter waiting: A `ClosedRange` of `TimeInterval`s.
        /// - returns: A modified copy of `self`.
        public func waiting(_ waiting: ClosedRange<TimeInterval>) -> Configuration {
            return copy(self) { $0.waiting = waiting }
        }

        // MARK: Accessories
        /// Instantiate an associated `URLSession`.
        /// - returns: A `URLSession` from the related `sessionConfiguration`.
        public func session() -> URLSession { return URLSession(configuration: sessionConfiguration) }
    }
}
