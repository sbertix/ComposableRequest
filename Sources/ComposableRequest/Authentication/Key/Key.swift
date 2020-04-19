//
//  Key.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/04/2020.
//

import Foundation

/// A `protocol` holding reference to authentication `HTTPCookie`s.
public protocol Key: Codable {
    /// A list of `CodableHTTPCookie`s.
    var cookies: [CodableHTTPCookie] { get }

    /// A custom `Dictionary`. Defaults to empty.
    var userInfo: [String: String] { get }
}
