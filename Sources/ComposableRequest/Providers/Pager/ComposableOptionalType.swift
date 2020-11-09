//
//  ComposableOptionalType.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 08/02/21.
//

import Foundation

/// A `protocol` defining a `ComposableRequest` abtrasction into `Optional`.
public protocol ComposableOptionalType {
    associatedtype Wrapped

    /// The associated `nil` value.
    static var optionalTypeNone: Self { get }
}

extension Optional: ComposableOptionalType {
    /// The associated `nil` value.
    public static var optionalTypeNone: Self { .none }
}
