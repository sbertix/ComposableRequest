//
//  Expected.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `struct` for changing the expected `Response`.
public struct Expected<Expecting: ComposableRequest.Expecting, Response: DataMappable>: Singular {
    /// The associated expectation.
    public var expecting: Expecting
}

/// Conditional conformacies to `Lockable`.
extension Expected: ComposableRequest.Lockable where Expecting: ComposableRequest.Lockable {
    /// Update as the `Unlockable` was unloacked.
    /// - parameters:
    ///     - unlockable: A valid `Unlockable`.
    ///     - secrets:  A `Dictionary` of `String` representing the authentication header fields.
    /// - warning: Do not call directly.
    public static func unlock(_ unlockable: ComposableRequest.Locked<Expected<Expecting, Response>>,
                              with secrets: [String: String]) -> Expected<Expecting, Response> {
        return copy(unlockable.lockable) { $0.expecting = Expecting.unlock($0.expecting.locked(), with: secrets) }
    }
}

/// Conditional conformacies to `Unlockable`.
extension Expected: Unlockable where Expecting: Unlockable, Expecting.Lockable: ComposableRequest.Expecting {
    /// The associated `Lockable`.
    public typealias Lockable = Expected<Expecting.Lockable, Response>

    /// Unlock the underlying `Locked`.
    /// - parameter secrets: A `Dictionary` of `String` representing the authentication header fields.
    public func authenticating(with secrets: [String: String]) -> Lockable {
        return .init(expecting: expecting.authenticating(with: secrets))
    }
}

/// Conditional conformacies to `Composable`.
extension Expected: Composable where Expecting: Composable { }
extension Expected: WrappedComposable where Expecting: Composable {
    /// A valid `Composable`.
    public var composable: Expecting {
        get { return expecting }
        set { expecting = newValue }
    }
}

/// Conditional conformacies to `Requestable`.
extension Expected: Requestable where Expecting: Requestable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? { return expecting.request() }
}
