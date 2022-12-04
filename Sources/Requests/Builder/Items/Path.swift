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
    let path: String
    
    /// Init.
    ///
    /// - parameter path: The path component for a given endpoint.
    public init(_ path: String) {
        self.path = path
    }
}
