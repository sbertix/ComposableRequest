//
//  Providers.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

/// A module-like `enum` listing all providers.
public enum Providers { }

// swiftlint:disable line_length
public extension Providers {
    /// A `typealias` for a composition of `Providers.Lock`,
    /// `Providers.Offset` and `Providers.Requester`.
    typealias LockOffsetRequester<I1, I2, I3: Requests.Requester, O: Receivable> = Lock<I1, Offset<I2, Requester<I3, O>>>

    /// A `typealias` for a composition of `Providers.Lock` and `Providers.Requester`.
    typealias LockRequester<I, I2: Requests.Requester, O: Receivable> = Lock<I, Requester<I2, O>>
}
// swiftlint:enable line_length
