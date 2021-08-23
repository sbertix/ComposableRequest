//
//  PagerInput.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 22/08/21.
//

import Foundation

/// A `protocol` defining an instance providing basic support for setting up a pager.
public protocol PagerInput {
    /// The associated offset type.
    associatedtype Offset

    /// The initial offset.
    var offset: Offset { get }
    /// The maximum pages count.
    var count: Int { get }

    /// Init.
    ///
    /// - parameters:
    ///     - offset: A valid `Offset`.
    ///     - count: A valid `Int`.
    init(offset: Offset, count: Int)
}
