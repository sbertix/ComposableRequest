//
//  PagerProvider.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/02/21.
//

import Foundation

/// A `struct` defining an offset provider.
public struct PagerProvider<Offset, Output>: PagerProviderType {
    /// The associated input type.
    public typealias Input = PagerProviderInput<Offset>

    /// The page generator.
    private let generator: (Input) -> Output

    /// Init.
    ///
    /// - parameter generator: A valid generator.
    public init(_ generator: @escaping (Input) -> Output) {
        self.generator = generator
    }

    // MARK: Provider

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
