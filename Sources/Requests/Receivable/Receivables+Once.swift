//
//  Receivables+Once.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 27/08/21.
//

import Foundation

public extension Receivables {
    /// A `struct` defining a `Requester`-based receivable
    /// receiving immediately either a success or failure.
    struct Once<Requester: Requests.Requester, Success>: Receivable {
        /// The underlying result.
        public let result: Result<Success, Error>

        /// Init.
        ///
        /// - parameters:
        ///     - success: A valid `Success`.
        ///     - requester: A valid `Requester`.
        public init(output success: Success, with requester: Requester) {
            self.result = .success(success)
        }

        /// Init.
        ///
        /// - parameters:
        ///     - failure: A valid `Error`.
        ///     - requester: A valid `Requester`.
        public init(error failure: Error, with requester: Requester) {
            self.result = .failure(failure)
        }
    }
}

public extension Requester {
    /// The associated once type.
    typealias Once<S> = Receivables.Once<Self, S>
}
