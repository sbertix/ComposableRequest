//
//  Projectable+Wrapper.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 24/02/21.
//

import Foundation

public extension Publisher where Output: Wrappable {
    /// Map to a `Wrapper`.
    ///
    /// - returns: A valid `Publisher`.
    func wrap() -> Publishers.Map<Self, Wrapper> {
        map(\.wrapped)
    }
}

public extension Publisher where Output == Data {
    /// Map to a `Wrapper`.
    ///
    /// - returns: A valid `Future`.
    func wrap() -> Publishers.TryMap<Self, Wrapper> {
        tryMap { try Wrapper.decode($0) }
    }
}

public extension Publisher where Output == Data? {
    /// Map to a `Wrapper`.
    ///
    /// - returns: A valid `Publisher`.
    func wrap() -> Publishers.TryMap<Self, Wrapper> {
        tryMap { try $0.flatMap(Wrapper.decode) ?? .empty }
    }
}
