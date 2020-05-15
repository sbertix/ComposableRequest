//
//  Key.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/04/2020.
//

import Foundation

/// A `protocol` holding reference to authentication.
public protocol Key: Codable { }

/// A `protocol` holding reference to authentication `HTTPCookie`s.
public protocol CookieKey: Key {
    /// A list of `CodableHTTPCookie`s.
    var cookies: [CodableHTTPCookie] { get }
}
