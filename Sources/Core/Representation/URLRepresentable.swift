//
//  URLRepresentable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/07/21.
//

import Foundation

/// A `protocol` defining a `URL` generator.
public protocol URLRepresentable {
    /// Compose an optional `URL`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URL`.
    static func url(from convertible: Self) -> URL?
}

extension String: URLRepresentable {
    /// Compose an optional `URL`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URL`.
    public static func url(from convertible: Self) -> URL? {
        URL(string: convertible)
    }
}

extension URL: URLRepresentable {
    /// Compose an optional `URL`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URL`.
    public static func url(from convertible: Self) -> URL? {
        convertible
    }
}

extension Optional: URLRepresentable where Wrapped: URLRepresentable {
    /// Compose an optional `URL`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URL`.
    public static func url(from convertible: Self) -> URL? {
        convertible.flatMap(Wrapped.url)
    }
}
