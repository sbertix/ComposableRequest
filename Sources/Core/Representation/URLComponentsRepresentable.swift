//
//  URLComponentsRepresentable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/07/21.
//

import Foundation

/// A `protcol` defining a `URLComponents` generator.
public protocol URLComponentsRepresentable: URLRepresentable {
    /// Compose an optional `URLComponents`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URLComponents`.
    static func components(from convertible: Self) -> URLComponents?
}

public extension URLComponentsRepresentable {
    /// Compose an optional `URL`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URL`.
    static func url(from convertible: Self) -> URL? {
        components(from: convertible)?.url
    }
}

extension URLComponents: URLComponentsRepresentable {
    /// Compose an optional `URLComponents`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URLComponents`.
    public static func components(from convertible: Self) -> URLComponents? {
        convertible
    }

    /// Attempt to append `component` to the `URL` representation.
    ///
    /// - parameter component: A valid `String`.
    /// - returns: A valid `Self`.
    public func path(appending component: String) -> Self {
        guard let url = url else { return self }
        return URLComponents(url: url.appendingPathComponent(component),
                             resolvingAgainstBaseURL: false) ?? self
    }
}

extension Optional: URLComponentsRepresentable where Wrapped: URLComponentsRepresentable {
    /// Compose an optional `URLComponents`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URLComponents`.
    public static func components(from convertible: Self) -> URLComponents? {
        convertible.flatMap(Wrapped.components)
    }
}
