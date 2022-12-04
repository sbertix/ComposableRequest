//
//  URLRequest.swift
//  Request
//
//  Created by Stefano Bertagno on 04/12/22.
//

import Foundation

extension URLRequest {
    /// Init.
    ///
    /// - parameters:
    ///     - path: A valid `String`.
    ///     - components: A valid `Component` dictionary.
    init?(path: String, components: [ObjectIdentifier: any Component]) {
        var copy = components
        // Make sure `Path` `value` is non-`nil`,
        // and add the `Query` items.
        guard var urlComponents = URLComponents(string: path) else {
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
        self = request
    }
}

private extension Dictionary where Key == ObjectIdentifier, Value == any Component {
    /// Get the cached component, or it's default value
    /// if it doesn't exist, then drop it.
    ///
    /// - parameter component: Some `Component` type.
    /// - returns: Some `Component`.
    mutating func drop<C: Component>(_ component: C.Type) -> C {
        removeValue(forKey: .init(component)) as? C ?? .defaultValue
    }
}
