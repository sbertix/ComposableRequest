//
//  Key.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/04/2020.
//

import Foundation

/// A `protocol` holding reference to authentication.
public protocol Key: Codable {
    /// The underlying identifier.
    var id: String { get }
}

/// A `protocol` holding reference to authentication headers.
public protocol HeaderKey: Key {
    /// A dictionary of headers.
    var header: [String: String] { get }
}

/// A `protocol` holding reference to authentication `HTTPCookie`s.
public protocol CookieKey: HeaderKey {
    /// A list of `CodableHTTPCookie`s.
    var cookies: [CodableHTTPCookie] { get }
}

/// An `extension` to simplify `Key` storage.
public extension Key {
    /// Init from `Storage`.
    /// - parameters:
    ///     - identifier: The `ds_user_id` cookie value.
    ///     - storage: A concrete-typed value conforming to the `Storage` protocol.
    static func stored<S: Storage>(with identifier: String, in storage: S) -> Self? where S.Key == Self {
        return storage.find(matching: identifier)
    }

    // MARK: Locker
    /// Store in `storage`.
    /// - parameter storage: A value conforming to the `Storage` protocol.
    @discardableResult
    func store<S: Storage>(in storage: S) -> Self where S.Key == Self {
        storage.store(self)
        return self
    }
}
