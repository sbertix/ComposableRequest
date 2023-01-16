//
//  Providers.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

/// A module-like `enum` listing all providers.
public enum Providers { }

public extension Providers {
    /// A `typealias` for a composition of `Providers.Lock` and `Providers.Offset`.
    typealias LockOffset<I1, I2, O> = Lock<I1, Offset<I2, O>>
}
