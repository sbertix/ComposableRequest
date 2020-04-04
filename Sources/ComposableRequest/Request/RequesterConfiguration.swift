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
        /// The default implementation for `Configuration`.
        public static var `default` = Configuration(sessionConfiguration: .default,
                                                    requestQueue: .main,
                                                    mapQueue: .global(qos: .userInitiated),
                                                    responseQueue: .main,
                                                    waiting: 0.0...0.0)

        /// A `URLSessionConfiguration`.
        public var sessionConfiguration: URLSessionConfiguration
        /// A valid `Queue` in which to perform requests.
        public var requestQueue: Queue
        /// A valid `Queue` in which to perform a `Completion`'s `Data` manipulation.
        public var mapQueue: Queue
        /// A valid `Queue` in which to deliver responses.
        public var responseQueue: Queue
        /// A range of `TimeInterval`s.
        /// A `randomElement()` in `waiting` will be spent waiting before every request.
        /// Defaults to `0.0...0.0`.
        public var waiting: ClosedRange<TimeInterval>

        // MARK: Lifecycle.
        /// Init.
        public init(sessionConfiguration: URLSessionConfiguration,
                    requestQueue: Queue,
                    mapQueue: Queue,
                    responseQueue: Queue,
                    waiting: ClosedRange<TimeInterval>) {
            self.sessionConfiguration = sessionConfiguration
            self.requestQueue = requestQueue
            self.mapQueue = mapQueue
            self.responseQueue = responseQueue
            self.waiting = waiting
        }

        /// Make it ephemeral.
        public func ephemeral() -> Configuration {
            return .init(sessionConfiguration: .ephemeral,
                         requestQueue: requestQueue,
                         mapQueue: mapQueue,
                         responseQueue: responseQueue,
                         waiting: waiting)
        }

        // MARK: Accessories
        /// Return an associated `URLSession`.
        public var session: URLSession { return URLSession(configuration: sessionConfiguration) }
    }
}
