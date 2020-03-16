//
//  Paginated.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `struct` for changing expected `Paginatable`s.
public struct Paginated<Expecting: ComposableRequest.Expecting, Response: DataMappable>: Paginatable {
    /// The `Expecting` value.
    public var expecting: Expecting
    /// The `name` of the `URLQueryItem` used for paginating.
    public var key: String
    /// The inital `value` of the `URLQueryItem` used for paginating.
    public var initial: String?
    /// The next `value` of the `URLQueryItem` user for paginating, based on the last `Response`.
    public var next: (Result<Response, Error>) -> String?
}

/// Conditional conformacies to `Lockable`.
extension Paginated: Lockable where Expecting: Lockable {
    /// Update as the `Unlockable` was unloacked.
    /// - parameters:
    ///     - unlockable: A valid `Unlockable`.
    ///     - secret:  A `Dictionary` of `String` representing the authentication header fields.
    /// - warning: Do not call directly.
    public static func unlock(_ unlockable: ComposableRequest.Locked<Paginated<Expecting, Response>>,
                              with secrets: [String: String]) -> Paginated<Expecting, Response> {
        return copy(unlockable.lockable) { $0.expecting = Expecting.unlock($0.expecting.locked(), with: secrets) }
    }
}

/// Conditional conformacies to `Unlockable`.
extension Paginated: Unlockable where Expecting: Unlockable, Expecting.Locked: ComposableRequest.Expecting {
    /// The associated `Lockable`.
    public typealias Locked = Paginated<Expecting.Locked, Response>

    /// Unlock the underlying `Locked`.
    /// - parameter secrets: A `Dictionary` of `String` representing the authentication header fields.
    public func authenticating(with secrets: [String: String]) -> Locked {
        return .init(expecting: expecting.authenticating(with: secrets),
                     key: key,
                     initial: initial,
                     next: next)
    }
}

/// Conditional conformacies to `Composable`.
extension Paginated: Composable where Expecting: Composable { }
extension Paginated: WrappedComposable where Expecting: Composable {
    /// A valid `Composable`.
    public var composable: Expecting {
        get { return expecting }
        set { expecting = newValue }
    }
}

/// Conditional conformacies to `Requestable`.
extension Paginated: Requestable where Expecting: Requestable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? { return expecting.request() }
}
