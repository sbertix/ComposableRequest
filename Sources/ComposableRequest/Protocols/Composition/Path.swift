//
//  Path.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

@dynamicMemberLookup
/// A `protocol` describing an instance providing the `URL` to some resouce in a `URLRequest`.
public protocol Path {
    /// The underlying request url components.
    var components: URLComponents? { get }

    /// Copy `self` and replace its `components`.
    ///
    /// - parameter components: An optional `URLComponents`.
    /// - returns: A valid `Self`.
    func components(_ components: URLComponents?) -> Self
}

public extension Path {
    /// Append `component` to `url`.
    ///
    /// - parameter component: A valid `String`.
    /// - returns: A valid `Self`.
    func path(appending component: String) -> Self {
        var components = self.components
            .flatMap { $0.url }
            .flatMap { URLComponents(url: $0.appendingPathComponent(component), resolvingAgainstBaseURL: false) }
        components?.queryItems = self.components?.queryItems
        return self.components(components)
    }

    /// Append `component` to `url`.
    ///
    /// - parameter component: A valid `String`.
    /// - returns: A valid `Self`.
    subscript(dynamicMember component: String) -> Self {
        path(appending: component)
    }
}
