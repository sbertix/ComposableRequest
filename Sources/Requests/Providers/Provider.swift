//
//  Provider.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `protocol` defining a value provider.
public protocol Provider {
    /// The associated input type.
    associatedtype Input
    /// The associated output type.
    associatedtype Output

    /// Init.
    ///
    /// - parameter generator: A valid generator.
    init(_ generator: @escaping (Input) -> Output)

    /// The actual factory.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameters:
    ///     - provider: A valid `Self`.
    ///     - input: A valid `Input`.
    /// - returns: A valid `Output`.
    static func generate(_ provider: Self, from input: Input) -> Output
}

public extension Provider where Output: Provider {
    /// Init.
    ///
    /// - parameter generator: A valid generator.
    init(_ generator: @escaping (Input, Output.Input) -> Output.Output) {
        self.init { input in .init { generator(input, $0) } }
    }
}

public extension Provider where Output: Provider,
                                Output.Output: Provider {
    /// Init.
    ///
    /// - parameter generator: A valid generator.
    init(_ generator: @escaping (Input, Output.Input, Output.Output.Input) -> Output.Output.Output) {
        self.init { input in .init { generator(input, $0, $1) } }
    }
}

public extension Provider where Output: Provider,
                                Output.Output: Provider,
                                Output.Output.Output: Provider {
    /// Init.
    ///
    /// - parameter generator: A valid generator.
    init(_ generator: @escaping (Input, Output.Input, Output.Output.Input, Output.Output.Output.Input) -> Output.Output.Output.Output) {
        self.init { input in .init { generator(input, $0, $1, $2) } }
    }
}

public extension Provider where Output: Provider,
                                Output.Output: Provider,
                                Output.Output.Output: Provider,
                                Output.Output.Output.Output: Provider {
    /// Init.
    ///
    /// - parameter generator: A valid generator.
    init(_ generator: @escaping (Input, Output.Input, Output.Output.Input, Output.Output.Output.Input, Output.Output.Output.Output.Input) -> Output.Output.Output.Output.Output) {
        self.init { input in .init { generator(input, $0, $1, $2, $3) } }
    }
}
