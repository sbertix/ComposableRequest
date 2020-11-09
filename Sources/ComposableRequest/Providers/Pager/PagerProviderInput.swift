//
//  PagerProviderInput.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `struct` defining a pager provider input.
public struct PagerProviderInput<Offset> {
    /// The number of pages.
    public let count: Int
    /// The actual offset.
    public let offset: Offset

    /// Init.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    public init(count: Int, offset: Offset) {
        self.count = count
        self.offset = offset
    }
}
