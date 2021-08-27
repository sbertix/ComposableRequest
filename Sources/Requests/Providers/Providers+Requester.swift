//
//  Providers+Requester.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

/// A `protocol` defining a provider requester type.
public protocol RequesterProvider: Provider where Output: Receivable {
    /// Update the requester.
    ///
    /// - parameter input: A valid `Input`.
    /// - returns: Some `Output`.
    func prepare(with requester: Input) -> Output
}

public extension RequesterProvider {
    /// Update the requester.
    ///
    /// - parameter input: A valid `Input`.
    /// - returns: Some `Output`.
    func prepare(with requester: Input) -> Output {
        Self.generate(self, from: requester)
    }
}

public extension Providers {
    /// A `struct` defining a requester provider.
    struct Requester<Input: Requests.Requester, Output: Receivable>: RequesterProvider {
        /// The output generator.
        private let generator: (Input) -> Output

        /// Init.
        ///
        /// - parameter generator: A valid generator.
        public init(_ generator: @escaping (Input) -> Output) {
            self.generator = generator
        }

        /// The actual factory.
        ///
        /// - note: This is implemented as a `static` method to hide its declaration.
        /// - parameters:
        ///     - provider: A valid `Self`.
        ///     - input: A valid `Input`.
        /// - returns: A valid `Output`.
        public static func generate(_ provider: Self, from input: Input) -> Output {
            provider.generator(input)
        }
    }
}

extension Providers.Requester: Paginatable where Input: Paginatable { }
