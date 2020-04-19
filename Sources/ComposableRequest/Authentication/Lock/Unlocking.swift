//
//  Unlocking.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 18/04/2020.
//

import Foundation

/// A `struct` holding reference to the ongoing unlocking process.
public struct Unlocking<Locked: Lockable> {
    /// A valid `Locked`.
    public var request: Locked
    /// A valid `Key`.
    public let key: Key

    /// Init.
    /// - parameters:
    ///     - request: A valid `Locked`.
    ///     - key: A valid `Key`.
    public init(request: Locked, key: Key) {
        self.request = request
        self.key = key
    }
}

/// A block representing the authentication process.
public typealias Authenticator<Locked: Lockable> = (Unlocking<Locked>) -> Locked

/// An extension allowing for a set of unlocking methods.
public extension Unlocking where Locked: Composable {
    /// Compose a list of `Authenticator`s together.
    /// - parameter authenticators: A list of `Authenticator`s.
    /// - returns: An `Authenticator` combining it all.
    static func concat(_ authenticators: Authenticator<Locked>...) -> Authenticator<Locked> {
        return concat(authenticators)
    }

    /// Compose a list of `Authenticator`s together.
    /// - parameter authenticators: An `Array` of `Authenticator`s.
    /// - returns: An `Authenticator` combining it all.
    static func concat(_ authenticators: [Authenticator<Locked>]) -> Authenticator<Locked> {
        return { authenticators.reduce(into: $0) { $0.request = $1($0) }.request }
    }

    #if swift(<5.2)
    /// Compose a list of `Authenticator`s together.
    /// - parameter keyPaths: A list of `KeyPath` on `Unlocking` returning `Locked`..
    /// - returns: An `Authenticator` combining it all.
    static func concat(_ authenticators: KeyPath<Unlocking, Locked>...) -> Authenticator<Locked> {
        return concat(authenticators.map { keyPath in { $0[keyPath: keyPath] }})
    }
    #endif

    /// Apply `key.header` to `request`.
    /// - returns: An unlocked `Locked`.
    var header: Locked { return request.header(HTTPCookie.requestHeaderFields(with: key.cookies)) }
}
