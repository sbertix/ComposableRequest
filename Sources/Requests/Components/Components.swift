//
//  Components.swift
//  Core
//
//  Created by Stefano Bertagno on 02/11/22.
//

import Foundation

/// A `struct` defining a collection of
/// all default and user-defined request
/// components.
public struct Components {
    /// The collection of all default and
    /// user-defined request components.
    var components: [ObjectIdentifier: any Component] = [:]

    /// Compose a `URLRequest` from
    /// existing `components`, if they're
    /// valid (really they just need to have
    /// a non-`nil` `Path` `value`).
    var request: URLRequest? {
        var copy = self
        // Make sure `Path` `value` is non-`nil`,
        // and add the `Query` items.
        guard let path = copy.drop(Path.self).value,
              var urlComponents = URLComponents(string: path) else {
            return nil
        }
        urlComponents.queryItems = copy.drop(Query.self).value
        // Compose the request.
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        // Update remaining standard components.
        copy.drop(Headers.self).update(&request)
        copy.drop(Body.self).update(&request)
        copy.drop(Method.self).update(&request)
        copy.drop(Cellular.self).update(&request)
        copy.drop(Service.self).update(&request)
        copy.drop(Timeout.self).update(&request)
        copy.drop(Constrained.self).update(&request)
        copy.drop(Expensive.self).update(&request)
        // Update user-defined ones.
        for (_, component) in components { component.update(&request) }
        return request
    }

    /// Get the cached component, or it's default value
    /// if it doesn't exist, then drop it.
    ///
    /// - parameter component: Some `Component` type.
    /// - returns: Some `Component`.
    mutating func drop<C: Component>(_ component: C.Type) -> C {
        components.removeValue(forKey: .init(component)) as? C ?? .defaultValue
    }
}
