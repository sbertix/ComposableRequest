//
//  Component.swift
//  Requests
//
//  Created by Stefano Bertagno on 02/11/22.
//

import Foundation

/// A `protocol` defining a unique identifier
/// for a specific request component.
///
/// The user can define custom components
/// to be used inside `EndpointBuilder`.
public protocol Component {
    /// The associated value type.
    associatedtype Value

    /// The default value when no cached
    /// component can be found.
    static var defaultValue: Self { get }

    /// The value connected to the current
    /// component.
    var value: Value { get }

    /// Inherit some previously cached value.
    /// Default implementation simply replaces
    /// the current value.
    ///
    /// ```
    /// Path("https://github.com")
    /// PathComponent("sbertix")
    /// PathComponent("ComposableRequest")
    /// ```
    /// would be resolved to the repo path.
    ///
    /// ```
    /// Headers("value1", forKey: "key1")
    /// Headers("value2", forKey: "key2")
    /// ```
    /// would be resolved to `["key1": "value1", "key2": "value2"]`.
    ///
    /// - note:
    ///     If there's no cached value, this will not be called,
    ///     instead the new one will replace the default one.
    /// - parameter original: The original value for the cached component.
    mutating func inherit(from original: any Component)

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

public extension Component {
    /// Inherit some previously cached value.
    /// Default implementation does nothing,
    /// meaning cached values are simply
    /// overridden.
    ///
    /// ```
    /// Path("https://github.com")
    /// PathComponent("sbertix")
    /// PathComponent("ComposableRequest")
    /// ```
    /// would be resolved to the repo path.
    ///
    /// ```
    /// Headers("value1", forKey: "key1")
    /// Headers("value2", forKey: "key2")
    /// ```
    /// would be resolved to `["key1": "value1", "key2": "value2"]`.
    ///
    /// - note:
    ///     If there's no cached value, this will not be called,
    ///     instead the new one will replace the default one.
    /// - parameter original: The original value for the cached component.
    mutating func inherit(from original: any Component) { }
}
