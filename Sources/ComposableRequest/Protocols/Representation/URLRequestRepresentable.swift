//
//  URLRequestRepresentable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/07/21.
//

import Foundation

/// A `protocol` defining a `URLRequest` generator.
public protocol URLRequestRepresentable: URLComponentsRepresentable {
    /// Compose an optional `URLRequest`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URLRequest`.
    static func request(from convertible: Self) -> URLRequest?
}

public extension URLRequestRepresentable {
    /// Compose an optional `URLComponents`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URLComponents`.
    static func components(from convertible: Self) -> URLComponents? {
        request(from: convertible)?.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
    }

    /// Compose an optional `URL`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URL`.
    static func url(from convertible: Self) -> URL? {
        request(from: convertible)?.url
    }
}

extension URLRequest: URLRequestRepresentable {
    /// Compose an optional `URLRequest`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URLRequest`.
    public static func request(from convertible: Self) -> URLRequest? {
        convertible
    }
}

extension Optional: URLRequestRepresentable where Wrapped: URLRequestRepresentable {
    /// Compose an optional `URLRequest`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URLRequest`.
    public static func request(from convertible: Self) -> URLRequest? {
        convertible.flatMap(Wrapped.request)
    }
}
