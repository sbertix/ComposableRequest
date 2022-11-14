//
//  ComponentsBuilder.swift
//  Core
//
//  Created by Stefano Bertagno on 02/11/22.
//

import Foundation

/// A `struct` defining a builder accepting
/// `Component`s and turning them into
/// `Components`.
///
/// - note:
///     Successive items for the same
///     `Component` will be replaced.
@resultBuilder public struct ComponentsBuilder {
    /// Build a collection of `Components`.
    ///
    /// - parameter components: A variadic collection of `Components`.
    /// - returns: Some `Components`.
    public static func buildBlock(_ components: Components...) -> Components {
        components.reduce(into: .init()) { $0.components.merge($1.components) { $1 } }
    }

    /// Build an optional `Components`.
    ///
    /// - parameter components: Some optional `Components`.
    /// - returns: Some `Components`.
    public static func buildOptional(_ component: Components?) -> Components {
        component ?? .init()
    }

    /// Build the first `Components`.
    ///
    /// - parameter components: Some `Components`.
    /// - returns: Some `Components`.
    public static func buildEither(first component: Components) -> Components {
        component
    }

    /// Build the last `Components`.
    ///
    /// - parameter components: Some `Components`.
    /// - returns: Some `Components`.
    public static func buildEither(last component: Components) -> Components {
        component
    }

    /// Build some availability-limited `Components`.
    ///
    /// - parameter components: Some `Components`.
    /// - returns: Some `Components`.
    public static func buildLimitedAvailability(_ component: Components) -> Components {
        component
    }

    /// Build some `Component`.
    ///
    /// - parameter component: Some `Component`.
    /// - returns: Some `Components`.
    public static func buildExpression<K: Component>(_ expression: K) -> Components {
        .init(components: [.init(K.self): expression])
    }
}
