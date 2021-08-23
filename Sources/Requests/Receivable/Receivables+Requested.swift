//
//  Receivables+Requested.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 23/08/21.
//

import Foundation

public extension Receivables {
    /// A `struct` defining a type-erased, `Requester`-based receivable.
    struct Requested<Requester: Requests.Requester, Success>: Receivable {
        /// The underlying reference.
        public let reference: Any

        /// Init.
        ///
        /// - parameter reference: Some `Any`.
        public init(reference: Any) {
            self.reference = reference
        }
    }
}

public extension Receivables.Requested {
    /// Type-erase the current receivable.
    ///
    /// - parameter requester: A concrete implementation of `Requester`.
    /// - returns: Some `Receivable`.
    func requested(by requester: Requester) -> Receivables.Requested<Requester, Success> {
        self
    }
}

public extension Requester {
    /// The associated requested type.
    typealias Requested<S> = Receivables.Requested<Self, S>
}
