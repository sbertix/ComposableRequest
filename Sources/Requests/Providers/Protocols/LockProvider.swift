//
//  LockProvider.swift
//  Core
//
//  Created by Stefano Bertagno on 17/11/22.
//

import Foundation

/// A `protocol` defining a provider abstracting
/// a lock, a padlock, requiring some key to be open.
public protocol LockProvider<Key, Secret>: Provider where Input == Key, Output == Secret {
    /// The associated lock key type.
    associatedtype Key
    /// The associated secret type.
    associatedtype Secret
    
    /// Unlock the output.
    ///
    /// - parameter key: Some `Key`.
    /// - returns: Some `Secret`.
    func unlock(with key: Key) -> Secret
}

public extension LockProvider {
    /// Generate an output.
    ///
    /// - parameter input: Some `Input`.
    /// - returns: Some `Output`.
    @_spi(Private) func _output(from input: Input) -> Output {
        unlock(with: input)
    }
}

public extension LockProvider where Input == Void {
    /// Unlock the output.
    ///
    /// - returns: Some `Secret`.
    func unlock() -> Secret {
        unlock(with: ())
    }
}
