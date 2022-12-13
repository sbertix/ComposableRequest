//
//  LockProvider.swift
//  Requests
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
    @_spi(Private)
    func _output(from input: Input) -> Output {
        unlock(with: input)
    }
}

public extension LockProvider {
    /// Unlock the output.
    ///
    /// - returns: Some `Secret`.
    func unlock() -> Secret where Input == Void {
        unlock(with: ())
    }

    /// Unlock the output.
    ///
    /// - returns: Some `Secret`.
    func unlock<T>() -> Secret where Input == T? {
        unlock(with: nil)
    }

    /// Unlock an optionally offsetted output.
    ///
    /// - parameter key: Some `Key`.
    /// - returns: Some `Secret.Output`.
    func unlock<T>(with key: Key) -> Secret.Output
    where Secret: OffsetProvider, Secret.Offset == T? {
        unlock(with: key).start()
    }

    /// Unlock an optionally offsetted output.
    ///
    /// - parameter key: Some `Key`.
    /// - returns: Some `Secret.Output`.
    func unlock<T>() -> Secret.Output where Input == Void, Secret: OffsetProvider, Secret.Offset == T? {
        unlock().start()
    }

    /// Unlock an optionally offsetted output.
    ///
    /// - parameter key: Some `Key`.
    /// - returns: Some `Secret.Output`.
    func unlock<T1, T2>() -> Secret.Output where Input == T1?, Secret: OffsetProvider, Secret.Offset == T2? {
        unlock().start()
    }
}
