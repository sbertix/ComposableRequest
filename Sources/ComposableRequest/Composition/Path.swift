//
//  Path.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` describing an instance providing the `URL` to some resouce in a `URLRequest`.
@dynamicMemberLookup
public protocol Path {
    /// The underlying request url components.
    var components: URLComponents? { get set }
}

public extension Path {
    /// Append `component`, to `url`.
    ///
    /// - parameter component: A valid `String`.
    /// - returns: A copy of `self`.
    func path(appending component: String) -> Self {
        var copy = self
        var components = copy.components
            .flatMap { $0.url }
            .flatMap { URLComponents(url: $0.appendingPathComponent(component), resolvingAgainstBaseURL: false) }
        components?.queryItems = copy.components?.queryItems
        copy.components = components
        return copy
    }

    /// Append `component`, to `url`.
    ///
    /// - parameter component: A valid `String`.
    /// - returns: A copy of `self`.
    subscript(dynamicMember component: String) -> Self {
        path(appending: component)
    }
}
