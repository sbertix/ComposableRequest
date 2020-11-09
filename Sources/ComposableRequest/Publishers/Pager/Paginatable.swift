//
//  Loopable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/03/21.
//

import Foundation

/// A `protocol` defining an instance declaring its own `Pager` offset.
public protocol Paginatable {
    /// The associated offset type.
    associatedtype Offset

    /// The actual offset.
    var offset: Offset { get }
}

public extension Publisher where Output: Paginatable {
    /// Create the iteration, after only one output.
    ///
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst() -> Pager<Output.Offset, Publishers.Output<Self>>.Iteration {
        iterateFirst { $0?.offset }
    }

    /// Create the iteration, on the last output alone.
    ///
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast() -> Pager<Output.Offset, Publishers.Last<Self>>.Iteration {
        iterateLast { $0?.offset }
    }
}

public extension Publisher where Output: Paginatable, Output.Offset: Equatable {
    /// Create the iteration, after only one output, making sure to not get stucked inside an infinite loop..
    ///
    /// - parameter exception: A valid `Offset`.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst(stoppingAt exception: Output.Offset) -> Pager<Output.Offset, Publishers.Output<Self>>.Iteration {
        iterateFirst(stoppingAt: exception) { $0?.offset }
    }

    /// Create the iteration, on the last output alone, making sure not to get stucked inside an infinite loop.
    ///
    /// - parameter exception: A valid `Offset`.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast(stoppingAt exception: Output.Offset) -> Pager<Output.Offset, Publishers.Last<Self>>.Iteration {
        iterateLast(stoppingAt: exception) { $0?.offset }
    }
}
