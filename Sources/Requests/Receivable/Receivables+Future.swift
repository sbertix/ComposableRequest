//
//  Receivables+Future.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 27/08/21.
//

import Foundation

public extension Receivables {
    /// A `struct` defining a future receivable.
    struct Future<Requester: Requests.Requester, Success>: Receivable {
        /// The completion handler.
        public let completion: (@escaping (Result<Success, Error>) -> Void) -> Void

        /// Init.
        ///
        /// - parameters:
        ///     - requester: A valid `Requester`.
        ///     - completion: A valid completion handler.
        public init(with requester: Requester, _ completion: @escaping (@escaping (Result<Success, Error>) -> Void) -> Void) {
            self.completion = completion
        }
    }
}
