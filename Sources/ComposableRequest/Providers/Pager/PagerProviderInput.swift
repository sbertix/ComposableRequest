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
    /// The delay.
    public let delay: (_ offset: Offset) -> Delay

    /// Init.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    ///     - delay: A valid `Delay` generator.
    public init(count: Int, offset: Offset, delay: @escaping (_ offset: Offset) -> Delay) {
        self.count = count
        self.offset = offset
        self.delay = delay
    }

    /// Init.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    ///     - delay: A valid `Delay`.
    public init(count: Int, offset: Offset, delay: Delay) {
        self.init(count: count, offset: offset) { _ in delay }
    }
}

public extension PagerProviderInput where Offset: Ranked {
    /// The underlying rank.
    var rank: Offset.Rank { offset.rank }
}
