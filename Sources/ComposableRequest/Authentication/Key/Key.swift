//
//  Key.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 16/03/2020.
//

import Foundation

/// A `struct` holding reference to authentication `HTTPCookie`s.
public struct Key: Codable {
    /// A list of `CodableHTTPCookie`s.
    /// - note: `cookies` is marked as `internal` in order to limit its abuse.
    internal let cookies: [CodableHTTPCookie]

    /// A custom `Dictionary`. Defaults to empty.
    public var userInfo: [String: String]

    /// Init.
    /// - parameters:
    ///     - cookies: A `Collection` of `HTTPCookie`s.
    ///     - userInfo: A valid `Dictionary`. Defaults to emoty.
    public init<Cookies: Collection>(cookies: Cookies,
                                     userInfo: [String: String] = [:]) where Cookies.Element: HTTPCookie {
        self.cookies = cookies.compactMap(CodableHTTPCookie.init)
        self.userInfo = userInfo
    }
}
