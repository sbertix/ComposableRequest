//
//  PagerProviderType.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `protocol` defining a specific provider.
public protocol PagerProviderType: Provider where Input == PagerProviderInput<Offset> {
    /// The associated offset type.
    associatedtype Offset
}

public extension PagerProviderType {
    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    /// - returns: Some `Content`.
    func pages(_ count: Int, offset: Offset) -> Output {
        Self.generate(self, from: .init(count: count, offset: offset))
    }
}

public extension PagerProviderType where Offset == Void {
    /// Authenticate.
    ///
    /// - parameter count: A valid `Int`.
    /// - returns: Some `Content`.
    func pages(_ count: Int) -> Output {
        self.pages(count, offset: ())
    }
}

public extension PagerProviderType where Offset: ComposableOptionalType {
    /// Authenticate.
    ///
    /// - parameter count: A valid `Int`.
    /// - returns: Some `Content`.
    func pages(_ count: Int) -> Output {
        self.pages(count, offset: .composableNone)
    }
}

public extension PagerProviderType where Offset: Ranked {
    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    ///     - rank: A valid `Rank`.
    /// - returns: Some `Content`.
    func pages(_ count: Int, offset: Offset.Offset, rank: Offset.Rank) -> Output {
        self.pages(count, offset: .init(offset: offset, rank: rank))
    }
}

public extension PagerProviderType where Offset: Ranked, Offset.Offset: ComposableOptionalType {
    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - rank: A valid `Rank`.
    /// - returns: Some `Content`.
    func pages(_ count: Int, rank: Offset.Rank) -> Output {
        self.pages(count, offset: .init(offset: .composableNone, rank: rank))
    }
}

public extension PagerProviderType where Offset: Ranked, Offset.Rank: ComposableOptionalType {
    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    /// - returns: Some `Content`.
    func pages(_ count: Int, offset: Offset.Offset) -> Output {
        self.pages(count, offset: .init(offset: offset, rank: .composableNone))
    }
}

public extension PagerProviderType
where Offset: Ranked, Offset.Offset: ComposableOptionalType, Offset.Rank: ComposableOptionalType {
    /// Set up pagination.
    ///
    /// - parameter count: A valid `Int`.
    /// - returns: Some `Content`.
    func pages(_ count: Int) -> Output {
        self.pages(count, offset: .init(offset: .composableNone, rank: .composableNone))
    }
}
