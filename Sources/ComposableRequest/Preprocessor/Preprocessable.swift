//
//  Preprocessable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Foundation

/// A `protocol` defining a transformation in `Request`.
public protocol Preprocessable {
    /// An associated `Preprocessed`.
    associatedtype Preprocessed: Requestable

    /// An associated `Preprocessor`.
    typealias Preprocessor = (_ request: Preprocessed) -> Preprocessed

    /// An optional transformation.
    var preprocessor: Preprocessor? { get }

    /// Update `preprocessor`.
    /// - parameter processor: An optional `Preprocessor`.
    /// - returns: An instance of `Self`.
    func replacing(preprocessor: Preprocessor?) -> Self
}

/// Default extension for `Preprocessable`.
public extension Preprocessable {
    /// Concat a new `Preprocessor` to `preprocessor`.
    /// - parameter processor: An optional `Preprocessor`.
    /// - returns: An instance of `Self`.
    func appending(preprocessor: @escaping Preprocessor) -> Self {
        return replacing(preprocessor: { preprocessor(self.preprocessor?($0) ?? $0) })
    }
}
