//
//  Loopable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/03/21.
//

import Foundation

/// A `protocol` defining an advanced paginatable instance, declaring its own `Pager` offset.
public protocol Instructable {
    /// The associated offset type.
    associatedtype Offset

    /// The associated instruction.
    var instruction: Instruction<Offset> { get }
}

/// A `protocol` defining an instance declaring its own `Pager` offset.
///
/// - note: Prefer conforming to `Instructable`, instead.
public protocol Paginatable: Instructable where Offset: ComposableNonNilType {
    /// The actual offset.
    var offset: Offset { get }
}

public extension Paginatable {
    /// The associated instruction.
    var instruction: Instruction<Offset> {
        offset.composableIsNone ? .stop : .load(offset)
    }
}

public extension Publisher where Output: Instructable {
    /// Create the iteration, after only one output.
    ///
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst() -> Pager<Output.Offset, Publishers.Output<Self>>.Iteration {
        iterateFirst { $0?.instruction ?? .stop }
    }

    /// Create the iteration, after only one output, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameter exception: A valid `Offset` handler. Return `true` to stop the stream.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst(stoppingAt exception: @escaping (Output.Offset) -> Bool) -> Pager<Output.Offset, Publishers.Output<Self>>.Iteration {
        iterateFirst(stoppingAt: exception) { $0?.instruction ?? .stop }
    }

    /// Create the iteration, on the last output alone.
    ///
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast() -> Pager<Output.Offset, Publishers.Last<Self>>.Iteration {
        iterateLast { $0?.instruction ?? .stop }
    }

    /// Create the iteration, on the last output alone., making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameter exception: A valid `Offset` handler. Return `true` to stop the stream.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast(stoppingAt exception: @escaping (Output.Offset) -> Bool) -> Pager<Output.Offset, Publishers.Last<Self>>.Iteration {
        iterateLast(stoppingAt: exception) { $0?.instruction ?? .stop }
    }
}

public extension Publisher where Output: Instructable, Output.Offset: Equatable {
    /// Create the iteration, after only one output, making sure to not get stucked inside an infinite loop..
    ///
    /// - parameter exception: A valid `Offset`.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst(stoppingAt exception: Output.Offset) -> Pager<Output.Offset, Publishers.Output<Self>>.Iteration {
        iterateFirst(stoppingAt: { $0 == exception })
    }

    /// Create the iteration, on the last output alone, making sure not to get stucked inside an infinite loop.
    ///
    /// - parameter exception: A valid `Offset`.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast(stoppingAt exception: Output.Offset) -> Pager<Output.Offset, Publishers.Last<Self>>.Iteration {
        iterateLast(stoppingAt: { $0 == exception })
    }
}
