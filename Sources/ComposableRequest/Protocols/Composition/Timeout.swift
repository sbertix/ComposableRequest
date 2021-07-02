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
    var timeout: TimeInterval { get }

    /// Copy `self` and replace its `timeout`.
    ///
    /// - parameter seconds: A valid `TimeInterval`.
    /// - returns: A valid `Self`.
    func timeout(after seconds: TimeInterval) -> Self
}
