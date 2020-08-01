//
//  AnyKey.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 16/03/2020.
//

import Foundation

/// A `struct` holding reference to authentication `HTTPCookie`s.
public struct AnyCookieKey: CookieKey {
    /// A valid identifier.
    public var id: String { String(cookies.hashValue) }
    /// A list of `CodableHTTPCookie`s.
    public let cookies: [CodableHTTPCookie]
    /// A dictionary of headers.
    public var header: [String: String] { return HTTPCookie.requestHeaderFields(with: cookies) }

    /// Init.
    /// - parameter cookies: A `Collection` of `HTTPCookie`s.
    public init<Cookies: Collection>(cookies: Cookies) where Cookies.Element: HTTPCookie {
        self.cookies = cookies.compactMap(CodableHTTPCookie.init)
    }

    /// Init.
    /// - parameter key: A valid `CookieKey`.
    public init<Key: CookieKey>(_ key: Key) {
        self.cookies = key.cookies
    }
}
