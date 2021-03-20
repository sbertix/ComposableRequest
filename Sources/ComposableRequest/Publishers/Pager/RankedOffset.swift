//
//  RankedOffset.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

/// A `protocol` defining an instance providing a rank token, other than an `Offset`.
public protocol Ranked {
    /// The associated offset type.
    associatedtype Offset
    /// The associated rank token type.
    associatedtype Rank

    /// The offset.
    var offset: Offset { get }
    /// The rank token.
    var rank: Rank { get }

    /// Init.
    ///
    /// - parameters:
    ///     - offset: A valid `Offset`.
    ///     - rank: A valid `Rank`.
    init(offset: Offset, rank: Rank)
}

/// A `struct` defining a ranked offset.
public struct RankedOffset<Offset, Rank>: Ranked {
    /// The offset.
    public var offset: Offset
    /// The rank token.
    public var rank: Rank

    /// Init.
    ///
    /// - parameters:
    ///     - offset: A valid `Offset`.
    ///     - rank: A valid `Rank`.
    public init(offset: Offset, rank: Rank) {
        self.offset = offset
        self.rank = rank
    }
}

extension RankedOffset: Equatable where Offset: Equatable {
    /// Compare offsets.
    ///
    /// - parameters:
    ///     - lhs: A valid `RankedOffset`.
    ///     - rhs: A valid `RankedOffset`.
    /// - returns: A valid `Bool`.
    public static func ==(lhs: RankedOffset, rhs: RankedOffset) -> Bool {
        lhs.offset == rhs.offset
    }
}
