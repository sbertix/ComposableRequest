//
//  ResultType.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/08/21.
//

import Foundation

/// A `protocol` defining a result type.
public protocol ResultType {
    /// The associated success type.
    associatedtype Success
    /// The associated failure type.
    associatedtype Failure: Error

    /// Compose a success.
    ///
    /// - parameter success: A valid `Success`.
    /// - returns: A valid `Self`.
    static func success(_ success: Success) -> Self

    /// Compose a failure.
    ///
    /// - parameter failure: A valid `Failure`.
    /// - returns: A valid `Self`.
    static func failure(_ failure: Failure) -> Self

    /// Turn into a result.
    ///
    /// - parameter result: A valid `Self`.
    /// - returns: A valid `Result`.
    /// - note: This is implemented as a `static` member to hide its definition.
    static func result(for result: Self) -> Result<Success, Failure>
}

extension Result: ResultType {
    /// Turn into a result.
    ///
    /// - parameter result: A valid `Self`.
    /// - returns: A valid `Result`.
    /// - note: This is implemented as a `static` member to hide its definition.
    public static func result(for result: Self) -> Result<Success, Failure> {
        result
    }
}
