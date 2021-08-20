//
//  Requester.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 18/08/21.
//

import Foundation

/// A `protocol` defining an instance capable of initiating network `Request`s.
public protocol Requester {
    /// The associated input type.
    associatedtype Input: RequesterInput
    /// The associated output type.
    associatedtype Output: Receivable where Output.Success == Request.Response

    /// The requester input.
    var input: Input { get }

    /// Init.
    ///
    /// - parameter input: A valid `Input`.
    init(_ input: Input)

    /// Prepare the request.
    ///
    /// - parameters:
    ///     - request: A valid `Request`.
    ///     - requester: A valid `Self`.
    /// - returns: A valid `Output`.
    /// - note: This is implemented as a `static` function to hide its definition. Rely on `request.prepare(with:)` instead.
    static func prepare(_ request: Request, with requester: Self) -> Output
}

public extension Request {
    /// Prepare the request.
    ///
    /// - parameter requester: A concrete instance of `Requester`.
    /// - returns: A valid `Requester.Output`.
    func prepare<R: Requester>(with requester: R) -> R.Output {
        R.prepare(self, with: requester)
    }
}
