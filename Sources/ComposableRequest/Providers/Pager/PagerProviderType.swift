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
    ///     - delay: A valid `Delay` generator.
    /// - returns: Some `Content`.
    func pages(_ count: Int, offset: Offset, delay: @escaping (_ offset: Offset) -> Delay) -> Output {
        Self.generate(self, from: .init(count: count, offset: offset, delay: delay))
    }

    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    ///     - delay: A valid `Delay`. Defaults to `0` seconds.
    /// - returns: Some `Content`.
    func pages(_ count: Int, offset: Offset, delay: Delay = .seconds(0)) -> Output {
        pages(count, offset: offset) { _ in delay }
    }

    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    ///     - delay: A valid `TimeInterval` range. The delay is randomized for every single page.
    /// - returns: Some `Content`.
    func pages(_ count: Int, offset: Offset, delay: ClosedRange<TimeInterval>) -> Output {
        pages(count, offset: offset) { _ in .seconds(.random(in: delay)) }
    }

    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    ///     - delay: A valid `TimeInterval` range. The delay is randomized for every single page.
    /// - returns: Some `Content`.
    func pages(_ count: Int, offset: Offset, delay: Range<TimeInterval>) -> Output {
        pages(count, offset: offset) { _ in .seconds(.random(in: delay)) }
    }
}

public extension PagerProviderType where Offset == Void {
    /// Authenticate.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - delay: A valid `Delay`. Defaults to `0` seconds.
    /// - returns: Some `Content`.
    func pages(_ count: Int, delay: Delay = .seconds(0)) -> Output {
        self.pages(count, offset: (), delay: delay)
    }
}

public extension PagerProviderType where Offset: ComposableOptionalType {
    /// Authenticate.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - delay: A valid `Delay`. Defaults to `0` seconds.
    /// - returns: Some `Content`.
    func pages(_ count: Int, delay: Delay = .seconds(0)) -> Output {
        self.pages(count, offset: .composableNone, delay: delay)
    }
}

public extension PagerProviderType where Offset: Ranked {
    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    ///     - rank: A valid `Rank`.
    ///     - delay: A valid `Delay`. Defaults to `0` seconds.
    /// - returns: Some `Content`.
    func pages(_ count: Int, offset: Offset.Offset, rank: Offset.Rank, delay: Delay = .seconds(0)) -> Output {
        self.pages(count, offset: .init(offset: offset, rank: rank), delay: delay)
    }
}

public extension PagerProviderType where Offset: Ranked, Offset.Offset: ComposableOptionalType {
    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - rank: A valid `Rank`.
    ///     - delay: A valid `Delay`. Defaults to `0`.
    /// - returns: Some `Content`.
    func pages(_ count: Int, rank: Offset.Rank, delay: Delay = .seconds(0)) -> Output {
        self.pages(count, offset: .init(offset: .composableNone, rank: rank), delay: delay)
    }
}

public extension PagerProviderType where Offset: Ranked, Offset.Rank: ComposableOptionalType {
    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - offset: A valid `Offset`.
    ///     - delay: A valid `Delay`. Defaults to `0` seconds.
    /// - returns: Some `Content`.
    func pages(_ count: Int, offset: Offset.Offset, delay: Delay = .seconds(0)) -> Output {
        self.pages(count, offset: .init(offset: offset, rank: .composableNone), delay: delay)
    }
}

public extension PagerProviderType
where Offset: Ranked, Offset.Offset: ComposableOptionalType, Offset.Rank: ComposableOptionalType {
    /// Set up pagination.
    ///
    /// - parameters:
    ///     - count: A valid `Int`.
    ///     - delay: A valid `Delay`. Defaults to `0` seconds.
    /// - returns: Some `Content`.
    func pages(_ count: Int, delay: Delay = .seconds(0)) -> Output {
        self.pages(count, offset: .init(offset: .composableNone, rank: .composableNone), delay: delay)
    }
}
