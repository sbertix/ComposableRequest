//
//  MethodComposable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// A `protocol` representing a composable `URLRequest` method.
public protocol MethodComposable {
    /// Replace the current `method` with `method`.
    /// - parameter method: A valid `Request.Method`.
    func replace(method: Request.Method) -> Self
}

/// A `protocol` representing a wrapped `MethodComposable`.
public protocol WrappedMethodComposable: MethodComposable {
    /// A valid `Method`.
    associatedtype Method: MethodComposable
    
    /// A valid `MethodComposable`.
    var methodComposable: Method { get set }
}
