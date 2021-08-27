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
    typealias LockOffsetRequester<I1, I2: PagerInput, I3: Requests.Requester, O: Receivable> = Lock<I1, Offset<I2, Requester<I3, O>>>

    /// A `typealias` for a composition of `Providers.Lock`,
    /// `Providers.Offset` and `Providers.Requester`.
    typealias LockPageRequester<I1, I2, I3: Requests.Requester, O: Receivable> = LockOffsetRequester<I1, Pages<I2>.Input, I3, O>

    /// A `typealias` for a composition of `Providers.Lock` and `Providers.Requester`.
    typealias LockRequester<I, I2: Requests.Requester, O: Receivable> = Lock<I, Requester<I2, O>>

    /// A `typealias` for a composition of `Providers.Offset` and `Providers.Requester`.
    typealias OffsetRequester<I1: PagerInput, I2: Requests.Requester, O: Receivable> = Offset<I1, Requester<I2, O>>

    /// A `typealias` for a composition of `Providers.Offset` and `Providers.Requester`.
    typealias PageRequester<I1, I2: Requests.Requester, O: Receivable> = OffsetRequester<Pages<I1>.Input, I2, O>
}
// swiftlint:enable line_length
