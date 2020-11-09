//
//  Timeout.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 03/11/20.
//

import Foundation

/// A `protocol` describing an instace providing the timeout interval for a `URLRequest`.
public protocol Timeout {
    /// The underlying timeout interval.
    var timeout: TimeInterval { get set }
}

public extension Timeout {
    /// Copy `self` and replace its `timeout`.
    ///
    /// - parameter seconds: A valid `TimeInterval`.
    /// - returns: A copy of `self`.
    func timeout(after seconds: TimeInterval) -> Self {
        var copy = self
        copy.timeout = seconds
        return copy
    }
}
