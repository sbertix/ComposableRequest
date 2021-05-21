//
//  Wrappable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 09/08/20.
//

import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

/// A `protocol` allowing to `init` `Wrapper`s.
public protocol Wrappable: CustomStringConvertible {
    /// Wrap `self` into a `Wrapper`.
    var wrapped: Wrapper { get }
}

public extension Wrappable {
    /// The description.
    ///
    /// - note: Override this for custom behavior.
    var description: String { wrapped.description }
}

extension Bool: Wrappable {
    /// Wrap `self` into a `Wrapper`.
    public var wrapped: Wrapper { .init(booleanLiteral: self) }
}

extension Int: Wrappable {
    /// Wrap `self` into a `Wrapper`.
    public var wrapped: Wrapper { .init(integerLiteral: self) }
}

extension Float: Wrappable {
    /// Wrap `self` into a `Wrapper`.
    public var wrapped: Wrapper { .init(floatLiteral: Double(self)) }
}

extension Double: Wrappable {
    /// Wrap `self` into a `Wrapper`.
    public var wrapped: Wrapper { .init(floatLiteral: self) }
}

extension String: Wrappable {
    /// Wrap `self` into a `Wrapper`.
    public var wrapped: Wrapper { .init(stringLiteral: self) }
}

extension NSNull: Wrappable {
    /// Wrap `self` into a `Wrapper`.
    public var wrapped: Wrapper { .empty }
}

extension Optional: CustomStringConvertible where Wrapped: Wrappable {
    /// The description.
    ///
    /// - note: Override this for custom behavior.
    public var description: String { self?.description ?? "<empty>" }
}

extension Optional: Wrappable where Wrapped: Wrappable {
    /// Wrap `self` into a `Wrapper`.
    public var wrapped: Wrapper { flatMap { $0.wrapped } ?? .empty }
}

extension Array: Wrappable where Element: Wrappable {
    /// Wrap `self` into a `Wrapper`.
    public var wrapped: Wrapper { .init(arrayLiteral: map { $0.wrapped }) }
}

extension Dictionary: Wrappable where Key == String, Value: Wrappable {
    /// Wrap `self` into a `Wrapper`.
    public var wrapped: Wrapper { .init(dictionaryLiteral: mapValues { $0.wrapped }) }
}

extension Wrapper: Wrappable {
    /// Return `self`.
    public var wrapped: Wrapper { self }
}

#if canImport(CoreGraphics)
extension CGFloat: Wrappable {
    /// Wrap `self` into a `Wrapper`.
    public var wrapped: Wrapper { .init(floatLiteral: Double(self)) }
}
#endif
