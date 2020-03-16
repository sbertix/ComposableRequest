//
//  Secreted.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 16/03/2020.
//

import Foundation

/// A `protocol` describing an item providing for authentication `httpHeaderFields`.
public protocol Secreted {
    /// A valid `Dictionary` of `String`s.
    var headerFields: [String: String] { get set }
}
