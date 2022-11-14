//
//  Component.swift
//  Core
//
//  Created by Stefano Bertagno on 02/11/22.
//

import Foundation

/// A `protocol` defining a unique identifier
/// for a specific request component.
///
/// The user can define custom components
/// to be used inside `ComponentsBuilder`.
public protocol Component {
    /// The associated value type.
    associatedtype Value

    /// The default value when no cached
    /// component can be found.
    static var defaultValue: Self { get }

    /// The value connected to the current
    /// component.
    var value: Value { get }

    /// Update a given `URLRequest`.
    ///
    /// - note:
    ///     User-defined `Component`s
    ///     are not guaranteed to run in
    ///     any specific order, only after
    ///     built-in ones.
    /// - parameter request: A mutable `URLRequest`.
    func update(_ request: inout URLRequest)
}
