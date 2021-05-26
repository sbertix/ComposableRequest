//
//  Pager+Iteration.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 18/03/21.
//

import Foundation

/// An `enum` listing all valid instructions.
public enum Instruction<Offset> {
    /// Stop paginating.
    case stop
    /// Load next offset.
    case load(Offset)
}

public extension Pager {
    /// A `struct` defining a valid `Publisher`
    /// iteration instance for `Pager`s.
    struct Iteration {
        /// The underlying stream.
        public let stream: Stream
        /// The underlying offset generator.
        public let offset: ([Output]) -> Instruction<Offset>
    }
}

public extension Publisher {
    /// Create the iteration.
    ///
    /// - parameter offset: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterate<O>(with offset: @escaping ([Output]) -> Instruction<O>) -> Pager<O, Self>.Iteration {
        .init(stream: self, offset: offset)
    }

    /// Create the iteration, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset` handler. Return `true` to stop the stream.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterate<O>(stoppingAt exception: @escaping (O) -> Bool,
                    with offset: @escaping ([Output]) -> Instruction<O>) -> Pager<O, Self>.Iteration {
        iterate { value -> Instruction<O> in
            let instruction = offset(value)
            guard case .load(let next) = instruction else { return instruction }
            return exception(next) ? .stop : .load(next)
        }
    }

    /// Create the iteration, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset`.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterate<O>(stoppingAt exception: O, with offset: @escaping ([Output]) -> Instruction<O>) -> Pager<O, Self>.Iteration where O: Equatable {
        iterate(stoppingAt: { $0 == exception }, with: offset)
    }

    /// Create the iteration, after only one output.
    ///
    /// - parameter offset: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst<O>(with offset: @escaping (Output?) -> Instruction<O>) -> Pager<O, Publishers.Output<Self>>.Iteration {
        prefix(1).iterate { offset($0.first) }
    }

    /// Create the iteration, after only one output, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset` handler. Return `true` to stop the stream.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst<O>(stoppingAt exception: @escaping (O) -> Bool, with offset: @escaping (Output?) -> Instruction<O>) -> Pager<O, Publishers.Output<Self>>.Iteration {
        iterateFirst { value -> Instruction<O> in
            let instruction = offset(value)
            guard case .load(let next) = instruction else { return instruction }
            return exception(next) ? .stop : .load(next)
        }
    }

    /// Create the iteration, after only one output, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset`.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst<O>(stoppingAt exception: O, with offset: @escaping (Output?) -> Instruction<O>) -> Pager<O, Publishers.Output<Self>>.Iteration where O: Equatable {
        iterateFirst(stoppingAt: { $0 == exception }, with: offset)
    }

    /// Create the iteration, on the last output alone.
    ///
    /// - parameter offset: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast<O>(with offset: @escaping (Output?) -> Instruction<O>) -> Pager<O, Publishers.Last<Self>>.Iteration {
        last().iterate { offset($0.first) }
    }

    /// Create the iteration, on the last output alone., making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset` handler. Return `true` to stop the stream.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast<O>(stoppingAt exception: @escaping (O) -> Bool, with offset: @escaping (Output?) -> Instruction<O>) -> Pager<O, Publishers.Last<Self>>.Iteration {
        iterateLast { value -> Instruction<O> in
            let instruction = offset(value)
            guard case .load(let next) = instruction else { return instruction }
            return exception(next) ? .stop : .load(next)
        }
    }

    /// Create the iteration, on the last output alone., making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset`.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast<O>(stoppingAt exception: O, with offset: @escaping (Output?) -> Instruction<O>) -> Pager<O, Publishers.Last<Self>>.Iteration where O: Equatable {
        iterateLast(stoppingAt: { $0 == exception }, with: offset)
    }

    /// Create a void iteration.
    ///
    /// - parameter continue: A valid offset boolean generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterate(_ `continue`: @escaping ([Output]) -> Bool = { _ in true }) -> Pager<Void, Self>.Iteration {
        .init(stream: self) { `continue`($0) ? .load(()) : .stop }
    }

    // MARK: Optional

    /// Create the iteration.
    ///
    /// - parameter offset: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterate<W>(with offset: @escaping ([Output]) -> Instruction<W>) -> Pager<W?, Self>.Iteration {
        self.iterate { value -> Instruction<W?> in
            switch offset(value) {
            case .stop:
                return .stop
            case .load(let offset):
                return .load(offset)
            }
        }
    }

    /// Create the iteration, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset` handler. Return `true` to stop the stream.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterate<W>(stoppingAt exception: @escaping (W?) -> Bool,
                    with offset: @escaping ([Output]) -> Instruction<W>) -> Pager<W?, Self>.Iteration {
        iterate { value -> Instruction<W> in
            let instruction = offset(value)
            guard case .load(let next) = instruction else { return instruction }
            return exception(next) ? .stop : .load(next)
        }
    }

    /// Create the iteration, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset`.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterate<W>(stoppingAt exception: W?, with offset: @escaping ([Output]) -> Instruction<W>) -> Pager<W?, Self>.Iteration where W: Equatable {
        iterate(stoppingAt: { $0 == exception }, with: offset)
    }

    /// Create the iteration, after only one output.
    ///
    /// - parameter offset: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst<W>(with offset: @escaping (Output?) -> Instruction<W>) -> Pager<W?, Publishers.Output<Self>>.Iteration {
        prefix(1).iterate { offset($0.first) }
    }

    /// Create the iteration, after only one output, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset` handler. Return `true` to stop the stream.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst<W>(stoppingAt exception: @escaping (W?) -> Bool, with offset: @escaping (Output?) -> Instruction<W>) -> Pager<W?, Publishers.Output<Self>>.Iteration {
        iterateFirst { value -> Instruction<W> in
            let instruction = offset(value)
            guard case .load(let next) = instruction else { return instruction }
            return exception(next) ? .stop : .load(next)
        }
    }

    /// Create the iteration, after only one output, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset`.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst<W>(stoppingAt exception: W?, with offset: @escaping (Output?) -> Instruction<W>) -> Pager<W?, Publishers.Output<Self>>.Iteration where W: Equatable {
        iterateFirst(stoppingAt: { $0 == exception }, with: offset)
    }

    /// Create the iteration, on the last output alone.
    ///
    /// - parameter offset: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast<W>(with offset: @escaping (Output?) -> Instruction<W>) -> Pager<W?, Publishers.Last<Self>>.Iteration {
        last().iterate { offset($0.first) }
    }

    /// Create the iteration, on the last output alone., making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset` handler. Return `true` to stop the stream.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast<W>(stoppingAt exception: @escaping (W?) -> Bool, with offset: @escaping (Output?) -> Instruction<W>) -> Pager<W?, Publishers.Last<Self>>.Iteration {
        iterateLast { value -> Instruction<W> in
            let instruction = offset(value)
            guard case .load(let next) = instruction else { return instruction }
            return exception(next) ? .stop : .load(next)
        }
    }

    /// Create the iteration, on the last output alone., making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset`.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast<W>(stoppingAt exception: W?, with offset: @escaping (Output?) -> Instruction<W>) -> Pager<W?, Publishers.Last<Self>>.Iteration where W: Equatable {
        iterateLast(stoppingAt: { $0 == exception }, with: offset)
    }
}

public extension Publisher where Failure == Never {
    // swiftlint:disable force_unwrapping
    /// Create the iteration, after only one output.
    ///
    /// - warning: The `Publisher` is still not guaranteed to return an output. You should only use this when you're certain it will.
    /// - parameter offset: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst<O>(with offset: @escaping (Output) -> Instruction<O>) -> Pager<O, Publishers.Output<Self>>.Iteration {
        iterateFirst { offset($0!) }
    }

    /// Create the iteration, after only one output, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset` handler. Return `true` to stop the stream.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst<O>(stoppingAt exception: @escaping (O) -> Bool, with offset: @escaping (Output) -> Instruction<O>) -> Pager<O, Publishers.Output<Self>>.Iteration {
        iterateFirst(stoppingAt: exception) { offset($0!) }
    }

    /// Create the iteration, after only one output, making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset`.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateFirst<O>(stoppingAt exception: O, with offset: @escaping (Output) -> Instruction<O>) -> Pager<O, Publishers.Output<Self>>.Iteration where O: Equatable {
        iterateFirst(stoppingAt: { $0 == exception }, with: offset)
    }

    /// Create the iteration, on the last output alone.
    ///
    /// - warning: The `Publisher` is still not guaranteed to return an output. You should only use this when you're certain it will.
    /// - parameter offset: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast<O>(with offset: @escaping (Output) -> Instruction<O>) -> Pager<O, Publishers.Last<Self>>.Iteration {
        iterateLast { offset($0!) }
    }

    /// Create the iteration, on the last output alone., making sure we don't get stuck inside an infinite loop.
    ///
    /// - parameters:
    ///     - exception: A valid `Offset` handler. Return `true` to stop the stream.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast<O>(stoppingAt exception: @escaping (O) -> Bool, with offset: @escaping (Output) -> Instruction<O>) -> Pager<O, Publishers.Last<Self>>.Iteration {
        iterateLast(stoppingAt: exception) { offset($0!) }
    }

    /// Create the iteration, on the last output alone., making sure we don't get stuck inside an infinite loop.
    ///
    /// - warning: The `Publisher` is still not guaranteed to return an output. You should only use this when you're certain it will.
    /// - parameters:
    ///     - exception: A valid `Offset`.
    ///     - offet: A valid offset generator.
    /// - returns: A valid `Pager.Iteration`.
    func iterateLast<O>(stoppingAt exception: O, with offset: @escaping (Output) -> Instruction<O>) -> Pager<O, Publishers.Last<Self>>.Iteration where O: Equatable {
        iterateLast(stoppingAt: { $0 == exception }, with: offset)
    }
    // swiftlint:enable force_unwrapping
}
