//
//  LockProviderType.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `protocol` defining a specific provider.
public protocol LockProviderType: Provider { }

public extension LockProviderType {
    /// Unlock.
    ///
    /// - parameter key: A valid `Key`.
    /// - returns: Some `Content`.
    func unlock(with key: Input) -> Output {
        Self.generate(self, from: key)
    }
}

public extension LockProviderType where Input == Void {
    /// Unlock.
    ///
    /// - returns: Some `Content`.
    func unlock() -> Output {
        Self.generate(self, from: ())
    }
}
