//
//  Path.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the path
/// component for a given endpoint.
public struct Path {
    /// The path.
    var path: String

    /// Init.
    ///
    /// - parameter path: The path component for a given endpoint.
    public init(_ path: String) {
        self.path = path
    }

    /// Inherit some previously cached value.
    /// Default implementation simply replaces
    /// the current value.
    ///
    /// ```
    /// Path("https://github.com")
    /// Path("sbertix")
    /// Path("ComposableRequest")
    /// ```
    /// would be resolved to the repo path.
    ///
    /// - parameter original: The original value for the cached component.
    public mutating func inherit(from original: Path) {
        switch true {
        case path.isEmpty:
            // If the new value is empty,
            // use the old one.
            path = original.path
        case original.path.isEmpty:
            // If the old value is empty,
            // use the new one, a.k.a. do
            // nothing.
            break
        default:
            // Otherwise, if they're both
            // valid, update it accordingly.
            path = original.path + "/" + path
        }
    }
}
