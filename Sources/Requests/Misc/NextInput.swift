//
//  NextInput.swift
//  Requests
//
//  Created by Stefano Bertagno on 16/11/22.
//

import Foundation

/// An `actor` holding reference to some
/// paginated request next `Input`.
actor NextInput<Input: Sendable> {
    /// The value of an optional next `Input`.
    var value: Input?

    /// Init.
    ///
    /// - parameter value: The initial next `Input`.
    init(_ value: Input? = nil) {
        self.value = value
    }

    /// Update next `Input`.
    ///
    /// - parameter value: The next `Input`.
    func update(with value: Input?) {
        self.value = value
    }
}
