//
//  ComposableOptionalType.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `protocol` defining a `ComposableRequest` abstraction for `nil`-checking `Optional`s.
public protocol ComposableNonNilType {
    /// Check whether it's `nil` or not.
    var composableIsNone: Bool { get }
}

/// A `protocol` defining a `ComposableRequest` abtrasction into `Optional`.
public protocol ComposableOptionalType: ComposableNonNilType {
    associatedtype Wrapped

    /// The associated `nil` value.
    static var composableNone: Self { get }

    /// Return the actual `Optional`.
    var composableOptional: Wrapped? { get }
}

extension ComposableOptionalType {
    /// Flat map the current value.
    ///
    /// - parameter transformer: A valid mapper.
    /// - returns: An optional value.
    func composableFlatMap<T>(_ transformer: (Wrapped) -> T?) -> T? {
        composableOptional.flatMap(transformer)
    }
}

extension Optional: ComposableOptionalType {
    /// The associated `nil` value.
    public static var composableNone: Self {
        .none
    }

    /// Check whether it's `nil` or not.
    public var composableIsNone: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }

    /// Return the actual `Optional`.
    public var composableOptional: Wrapped? {
        self
    }
}
