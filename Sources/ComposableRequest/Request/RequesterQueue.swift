//
//  RequesterQueue.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

public extension Requester {
    /// A `struct` referencing the different states' `Queue`s.
    struct Dispatcher: Hashable {
        /// A `Queue` to be used to perform requests. Defaults to `.main`.
        public var request: Queue
        /// A `Queue` to be used to perform transformations. Defaults to `.global(qos: .userInitiated)`.
        public var process: Queue
        /// A `Queue` to be used to deliver responses. Defaults to `.main`.
        public var response: Queue

        /// Init.
        /// - parameters:
        ///     - request: A valid `Queue`. Defaults to `.main`.
        ///     - process: A valid `Queue`. Defaults to `.global(qos: .userInitiated)`.
        ///     - response: A valid `Queue`. Defaults to `.main`.
        public init(request: Queue = .main,
                    process: Queue = .global(qos: .userInitiated),
                    response: Queue = .main) {
            self.request = request
            self.process = process
            self.response = response
        }
    }

    /// An `enum` identifying `DispatchQueue`s.
    enum Queue: Hashable {
        /// `DispatchQueue.main`
        case main
        /// The global `DispatchQueue` matching `qos` quality of service.
        case global(qos: DispatchQoS.QoSClass)

        /// The associated `DispatchQueue`.
        internal var dispatchQueue: DispatchQueue {
            switch self {
            case .main: return .main
            case .global(let qualityOfService): return .global(qos: qualityOfService)
            }
        }

        /// Perform `block` on the correct `DispatchQueue`.
        /// - parameters:
        ///     - waiting: A `ClosedRange` of `TimeInterval`s. Not applied on `.current`.
        ///     - work: The block that needs executing.
        internal func handle(waiting: ClosedRange<TimeInterval> = 0...0, _ work: @escaping () -> Void) {
            dispatchQueue.asyncAfter(deadline: .now()+TimeInterval.random(in: waiting),
                                     execute: work)
        }
    }
}
