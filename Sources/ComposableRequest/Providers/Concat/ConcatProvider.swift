//
//  ConcatProvider.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `struct` defining a composition of `Provider`s.
public struct ConcatProvider<A: Provider, B: Provider>: Provider where A.Output == B {
    /// The associated input type.
    public typealias Input = A.Input
    /// The associated output type.
    public typealias Output = B

    /// The output generator.
    private let generator: (Input) -> Output

    /// Init.
    ///
    /// - parameter generator: A valid generator.
    @available(*, deprecated, message: "use concat `init` on nested `A` directly (removing on `6.0.0`)")
    public init(_ generator: @escaping (Input) -> Output) {
        self.generator = generator
    }

    /// Init.
    ///
    /// - parameter generator: A valid generator.
    @available(*, deprecated, message: "use concat `init` on nested `A` directly (removing on `6.0.0`)")
    public init(_ generator: @escaping (A.Input, B.Input) -> B.Output) {
        self.generator = { input in .init { generator(input, $0) } }
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

extension ConcatProvider: LockProviderType where A: LockProviderType { }
extension ConcatProvider: PagerProviderType where A: PagerProviderType {
    public typealias Offset = A.Offset
}
extension ConcatProvider: SessionProviderType where A: SessionProviderType { }
