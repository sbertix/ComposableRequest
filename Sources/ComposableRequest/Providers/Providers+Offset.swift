//
//  Providers+Offset.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

/// A `protocol` defining a provider offset type.
public protocol OffsetProvider: Provider {
    /// Start at a given offset.
    ///
    /// - parameter offset: A valid `Input`.
    /// - returns: Some `Content`.
    func offset(_ offset: Input) -> Output
}

public extension OffsetProvider {
    /// Start at a given offset.
    ///
    /// - parameter offset: A valid `Input`.
    /// - returns: Some `Content`.
    func offset(_ offset: Input) -> Output {
        Self.generate(self, from: offset)
    }
}

public extension Providers {
    /// A `struct` defining a page offseter.
    struct Offset<Input, Output>: OffsetProvider {
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
