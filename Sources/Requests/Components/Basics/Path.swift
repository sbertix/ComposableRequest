//
//  Path.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// A `struct` defining the last path
/// component for a given endpoint.
public struct Path: Component {
    /// The default value when no cached
    /// component can be found.
    public static var defaultValue: Path {
        .init(nil)
    }

    /// The last path component for a given endpoint.
    /// We use `nil` to identify that path has not been set.
    public let value: String?

    /// Init.
    ///
    /// - parameter path: The last path component for a given endpoint.
    private init(_ path: String?) {
        self.value = path
    }

    /// Init.
    ///
    /// - parameter path: The last path component for a given endpoint.
    public init(_ path: String) {
        self.value = path
    }

    /// Update a given `URLRequest`.
    ///
    /// - parameter request: A mutable `URLRequest`.
    public func update(_ request: inout URLRequest) {
        // `Path` has already been
        // set at this point.
    }
}
