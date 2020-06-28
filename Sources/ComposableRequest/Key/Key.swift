//
//  Key.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/04/2020.
//

import Foundation

/// A `protocol` holding reference to authentication.
public protocol Key: Codable { }

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
