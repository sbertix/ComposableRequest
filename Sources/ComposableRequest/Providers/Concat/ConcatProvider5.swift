//
//  ConcatProvider5.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `struct` defining a composition of `Provider`s.
public struct ConcatProvider5<A: Provider,
                              B: Provider,
                              C: Provider,
                              D: Provider,
                              E: Provider>: Provider
where A.Output == B, B.Output == C, C.Output == D, D.Output == E {
    /// The associated input type.
    public typealias Input = A.Input
    /// The associated output type.
    public typealias Output = ConcatProvider4<B, C, D, E>

    /// The output generator.
    private let generator: (Input) -> Output

    /// Init.
    ///
    /// - parameter generator: A valid generator.
    public init(_ generator: @escaping (Input) -> Output) {
        self.generator = generator
    }

    /// Init.
    ///
    /// - parameter generator: A valid generator.
    public init(_ generator: @escaping (A.Input, B.Input, C.Input, D.Input, E.Input) -> E.Output) {
        self.generator = { input in .init { generator(input, $0, $1, $2, $3) } }
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

extension ConcatProvider5: LockProviderType where A: LockProviderType { }
extension ConcatProvider5: PagerProviderType where A: PagerProviderType {
    public typealias Offset = A.Offset
}
extension ConcatProvider5: SessionProviderType where A: SessionProviderType { }
