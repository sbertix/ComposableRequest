//
//  Provider+EndpointBuilder.swift
//  Requests
//
//  Created by Stefano Bertagno on 06/12/22.
//

import Foundation

public extension Provider {
    /// Init.
    ///
    /// - parameter content: The endpoint factory.
    init<O>(@EndpointBuilder _ content: @escaping (Input) -> Single<O>) where Output == Single<O> {
        self.init { content($0) }
    }

    /// Init.
    ///
    /// - parameter content: The endpoint factory.
    init<O>(@EndpointBuilder _ content: @escaping (Input, Output.Input) -> Single<O>)
    where Output: Provider, Output.Output == Single<O> {
        self.init { content($0, $1) }
    }

    /// Init.
    ///
    /// - parameter content: The endpoint factory.
    init<O>(
        @EndpointBuilder _ content: @escaping (
            Input,
            Output.Input,
            Output.Output.Input
        ) -> Single<O>
    ) where Output: Provider,
            Output.Output: Provider,
            Output.Output.Output == Single<O> {
        self.init { content($0, $1, $2) }
    }

    /// Init.
    ///
    /// - parameter content: The endpoint factory.
    init<O>(
        @EndpointBuilder _ content: @escaping (
            Input,
            Output.Input,
            Output.Output.Input,
            Output.Output.Output.Input
        ) -> Single<O>
    ) where Output: Provider,
            Output.Output: Provider,
            Output.Output.Output: Provider,
            Output.Output.Output.Output == Single<O> {
        self.init { content($0, $1, $2, $3) }
    }

    /// Init.
    ///
    /// - parameter content: The endpoint factory.
    init<O>(
        @EndpointBuilder _ content: @escaping (
            Input,
            Output.Input,
            Output.Output.Input,
            Output.Output.Output.Input,
            Output.Output.Output.Output.Input
        ) -> Single<O>
    ) where Output: Provider,
            Output.Output: Provider,
            Output.Output.Output: Provider,
            Output.Output.Output.Output: Provider,
            Output.Output.Output.Output.Output == Single<O> {
        self.init { content($0, $1, $2, $3, $4) }
    }
}
