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

    /// Init.
    ///
    /// - parameter components: The initial `Component`s.
    init<C: Collection>(_ components: C = []) where C.Element == any Component {
        self.components = components.reduce(into: [:]) { $0[.init(type(of: $1))] = $1 }
    }

    /// Inherit some previously cached value.
    ///
    /// - parameter original: The original value for the cached components.
    mutating func inherit(from original: Components) {
        components.merge(original.components) { new, old in
            var new = new
            new.inherit(from: old)
            return new
        }
        print("CIAONE", components)
    }
}
