//
//  PathComposable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 04/05/2020.
//

import Foundation

/// A `protocol` representing a composable `URLRequest` path.
@dynamicMemberLookup
public protocol PathComposable {
    /// Append `pathComponent` to the current `path`.
    /// - parameter pathComponent: A `String` representing a path component.
    func append(path pathComponent: String) -> Self
}

public extension PathComposable {
    /// Append `pathComponent` to the current `path`.
    /// - parameter pathComponent: A `String` representing a path component.
    subscript(dynamicMember pathComponent: String) -> Self {
        return append(path: pathComponent)
    }
}
