//
//  Providers+Lock.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/02/21.
//

import Foundation

/// A `protocol` defining a provider lock type.
public protocol LockProvider: Provider {
    /// Unlock.
    ///
    /// - parameter key: A valid `Input`.
    /// - returns: Some `Content`.
    func unlock(with key: Input) -> Output
}

public extension LockProvider {
    /// Unlock.
    ///
    /// - parameter key: A valid `Input`.
    /// - returns: Some `Content`.
    func unlock(with key: Input) -> Output {
        Self.generate(self, from: key)
    }
}

public extension LockProvider where Input == Void {
    /// Unlock.
    ///
    /// - returns: Some `Content`.
    func unlock() -> Output {
        unlock(with: ())
    }
}

public extension LockProvider where Output: OffsetProvider, Output.Input: ComposableOptionalType {
    /// Unlock.
    ///
    /// - parameter key: A valid `Input`.
    /// - returns: Some `Content`.
    func unlock(with key: Input) -> Output.Output {
        unlock(with: key).offset(.composableNone)
    }
}

public extension LockProvider where Output: OffsetProvider, Output.Input == Void {
    /// Unlock.
    ///
    /// - parameter key: A valid `Input`.
    /// - returns: Some `Content`.
    func unlock(with key: Input) -> Output.Output {
        unlock(with: key).offset(())
    }
}

public extension LockProvider where Output: OffsetProvider, Input == Void, Output.Input: ComposableOptionalType {
    /// Unlock.
    ///
    /// - returns: Some `Content`.
    func unlock() -> Output.Output {
        unlock(with: ())
    }
}

public extension LockProvider where Output: OffsetProvider, Input == Void, Output.Input == Void {
    /// Unlock.
    ///
    /// - returns: Some `Content`.
    func unlock() -> Output.Output {
        unlock(with: ())
    }
}

public extension Providers {
    /// A `struct` defining an authenticator.
    struct Lock<Input, Output>: LockProvider {
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
