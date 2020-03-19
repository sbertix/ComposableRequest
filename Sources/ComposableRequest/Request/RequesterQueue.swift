//
//  RequesterQueue.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

public extension Requester {
    /// An `enum` identifying `DispatchQueue`s.
    enum Queue: Hashable {
        /// The current `DispatchQueue`.
        case current
        /// `DispatchQueue.main`
        case main
        /// The global `DispatchQueue` matching quality of service.
        case global(qos: DispatchQoS.QoSClass)

        /// Perform `block` on the correct `DispatchQueue`.
        /// - parameters:
        ///     - waiting: A `ClosedRange` of `TimeInterval`s. Not applied on `.current`.
        ///     - work: The block that needs executing.
        internal func handle(waiting: ClosedRange<TimeInterval> = 0...0, _ work: @escaping () -> Void) {
            switch self {
            case .current:
                work()
            case .main:
                DispatchQueue.main
                    .asyncAfter(deadline: .now()+TimeInterval.random(in: waiting),
                                execute: work)
            case .global(let qos):
                DispatchQueue.global(qos: qos)
                    .asyncAfter(deadline: .now()+TimeInterval.random(in: waiting),
                                execute: work)
            }
        }
    }
}
