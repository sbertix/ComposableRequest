//
//  Providers+Offset.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

/// A `protocol` defining a provider offset type.
public protocol OffsetProvider: Provider where Input: PagerInput {
    /// Start at a given offset.
    ///
    /// - parameter offset: A valid `Input.Offset`.
    /// - returns: Some `Content`.
    func offset(_ offset: Input.Offset) -> Output
}

public extension OffsetProvider {
    /// Start at a given offset.
    ///
    /// - parameter offset: A valid `Input.Offset`.
    /// - returns: Some `Content`.
    func offset(_ offset: Input.Offset) -> Output {
        Self.generate(self, from: .init(offset: offset, count: 1))
    }
}

public extension OffsetProvider where Output: Paginatable {
    /// Start at a given offset and paginate from there.
    ///
    /// - parameters:
    ///     - offset: A valid `Input.Offset`.
    ///     - pages: A valid `Int`.
    /// - returns: Some `Content`.
    func offset(_ offset: Input.Offset, pages: Int) -> Output {
        Self.generate(self, from: .init(offset: offset, count: pages))
    }
}

public extension Providers {
    /// A `struct` defining a page offseter.
    struct Offset<Input: PagerInput, Output>: OffsetProvider {
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

        /// Start at a given offset.
        ///
        /// - parameter offset: A valid `Input`.
        /// - returns: Some `Content`.
        public func offset(_ offset: Input) -> Output {
            Self.generate(self, from: offset)
        }
    }
}
