//
//  AnyKey.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 16/03/2020.
//

import Foundation

/// A `struct` holding reference to authentication `HTTPCookie`s.
public struct AnyCookieKey: CookieKey {
    /// A list of `CodableHTTPCookie`s.
    /// - note: `cookies` is marked as `internal` in order to limit its abuse.
    public let cookies: [CodableHTTPCookie]

    /// Init.
    /// - parameters:
    ///     - cookies: A `Collection` of `HTTPCookie`s.
    ///     - userInfo: A valid `Dictionary`. Defaults to emoty.
    public init<Cookies: Collection>(cookies: Cookies) where Cookies.Element: HTTPCookie {
        self.cookies = cookies.compactMap(CodableHTTPCookie.init)
    }

    /// Init.
    /// - parameter key: A valid `CookieKey`.
    public init(_ key: CookieKey) {
        self.cookies = key.cookies
    }
}
