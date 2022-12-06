//
//  Provider.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `protocol` defining a value provider.
public protocol Provider<Input, Output> {
    /// The associated input type, passed to generate the output.
    associatedtype Input
    /// The associated output type, generated by some given input.
    associatedtype Output

    /// Init.
    ///
    /// - parameter content: The output factory.
    init(_ content: @escaping (Input) -> Output)

    /// Generate an output.
    ///
    /// - parameter input: Some `Input`.
    /// - returns: Some `Output`.
    @_spi(Private)
    func _output(from input: Input) -> Output
}

public extension Provider {
    /// Init.
    ///
    /// - parameter content: The output factory.
    init(_ content: @escaping (Input, Output.Input) -> Output.Output) where Output: Provider {
        self.init { input in .init { content(input, $0) } }
    }

    /// Init.
    ///
    /// - parameter content: The output factory.
    init(
        _ content: @escaping (
            Input,
            Output.Input,
            Output.Output.Input
        ) -> Output.Output.Output
    ) where Output: Provider,
            Output.Output: Provider {
        self.init { input in .init { content(input, $0, $1) } }
    }

    /// Init.
    ///
    /// - parameter content: The output factory.
    init(
        _ content: @escaping (
            Input,
            Output.Input,
            Output.Output.Input,
            Output.Output.Output.Input
        ) -> Output.Output.Output.Output
    ) where Output: Provider,
            Output.Output: Provider,
            Output.Output.Output: Provider {
        self.init { input in .init { content(input, $0, $1, $2) } }
    }

    /// Init.
    ///
    /// - parameter content: The output factory.
    init(
        _ content: @escaping (
            Input,
            Output.Input,
            Output.Output.Input,
            Output.Output.Output.Input,
            Output.Output.Output.Output.Input
        ) -> Output.Output.Output.Output.Output
    ) where Output: Provider,
            Output.Output: Provider,
            Output.Output.Output: Provider,
            Output.Output.Output.Output: Provider {
        self.init { input in .init { content(input, $0, $1, $2, $3) } }
    }
}
