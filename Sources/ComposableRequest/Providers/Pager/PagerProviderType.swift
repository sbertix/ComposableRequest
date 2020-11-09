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
        self.pages(count, offset: .optionalTypeNone)
    }
}
