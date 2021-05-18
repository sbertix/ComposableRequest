//
//  Pager.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 18/03/21.
//

import Foundation

public extension Publishers {
    /// A `struct` defining a `Publisher` emitting a sequence
    /// of outputs, until it fails or completes.
    struct Pager<Offset, Stream: Publisher>: Publisher {
        /// The associated output type.
        public typealias Output = Stream.Output
        /// The associated failure type.
        public typealias Failure = Stream.Failure

        /// The maximum number of complete iterations.
        /// This is not the maximum number of outputs, instead is the
        /// maximum number of subscriber (and completed) `Stream`s.
        private let count: Int
        /// The current offset.
        private let offset: Offset
        /// The iteration generator.
        private let generator: (_ offset: Offset) -> Iteration

        /// Init.
        ///
        /// - parameters:
        ///     - count: A valid `Int`. Defaults to `.max`.
        ///     - offset: A valid `Offset`.
        ///     - generator: A valid generator.
        public init(_ count: Int = .max,
                    offset: Offset,
                    generator: @escaping (_ offset: Offset) -> Iteration) {
            self.count = count
            self.offset = offset
            self.generator = generator
        }

        /// Init.
        ///
        /// - parameters:
        ///     - pages: A valid `PagesProviderInput`.
        ///     - generator: A valid generator.
        public init(_ pages: PagerProviderInput<Offset>,
                    generator: @escaping (_ offset: Offset) -> Iteration) {
            self.init(pages.count, offset: pages.offset, generator: generator)
        }

        /// Receive a subscriber.
        ///
        /// - parameter subscriber: A valid subscriber.
        public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
            // Make sure there's demand for it.
            guard count > 0 else {
                Empty().subscribe(subscriber)
                return
            }
            // Prepare the iterator.
            let iterator = generator(offset)
            iterator.stream
                .collect()
                .flatMap { [count, generator] outputs -> AnyPublisher<Output, Failure> in
                    // The current publisher.
                    let current = Publishers.Sequence(sequence: outputs.map(Just.init))
                        .flatMap(maxPublishers: .max(1)) { $0 }
                        .setFailureType(to: Failure.self)
                    // The next instruction.
                    switch iterator.offset(outputs) {
                    case .stop:
                        return current.eraseToAnyPublisher()
                    case .load(let next):
                        return current
                            .append(Pager(count-1, offset: next, generator: generator))
                            .eraseToAnyPublisher()
                    }
                }
                .subscribe(subscriber)
        }
    }
}

/// A `typealias` for `Publishers.Pager`.
public typealias Pager = Publishers.Pager

public extension Pager where Offset == Void {
    /// Init.
    ///
    /// - parameters:
    ///     - count: A valid `Int`. Defaults to `.max`.
    ///     - generator: A valid generator.
    init(_ count: Int = .max, generator: @escaping () -> Iteration) {
        self.init(count, offset: ()) { _ in generator() }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - pages: A valid `PagesProviderInput`.
    ///     - generator: A valid generator.
    init(_ pages: PagerProviderInput<Offset>, generator: @escaping () -> Iteration) {
        self.init(pages) { _ in generator() }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - count: A valid `Int`. Defaults to `.max`.
    ///     - generator: A valid generator.
    init(_ count: Int = .max, generator: @escaping () -> Stream) {
        self.init(count, offset: ()) { _ in generator().iterate() }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - pages: A valid `PagesProviderInput`.
    ///     - generator: A valid generator.
    init(_ pages: PagerProviderInput<Offset>, generator: @escaping () -> Stream) {
        self.init(pages) { _ in generator().iterate() }
    }
}

public extension Pager where Offset: ComposableOptionalType {
    /// Init.
    ///
    /// - parameters:
    ///     - count: A valid `Int`. Defaults to `.max`.
    ///     - generator: A valid generator.
    init(_ count: Int = .max, generator: @escaping (_ offset: Offset) -> Iteration) {
        self.init(count, offset: .composableNone, generator: generator)
    }
}

public extension Pager where Offset: Ranked {
    /// Init.
    ///
    /// - parameters:
    ///     - count: A valid `Int`. Defaults to `.max`.
    ///     - offset: A valid `Offset`.
    ///     - generator: A valid generator.
    init(_ count: Int = .max,
         offset: Offset,
         generator: @escaping (_ offset: Offset.Offset) -> Pager<Offset.Offset, Stream>.Iteration) {
        self.init(count, offset: offset) { offset -> Iteration in
            let iteration = generator(offset.offset)
            return .init(stream: iteration.stream) {
                switch iteration.offset($0) {
                case .stop:
                    return .stop
                case .load(let next):
                    return .load(.init(offset: next, rank: offset.rank))
                }
            }
        }
    }

    /// Init.
    ///
    /// - parameters:
    ///     - pages: A valid `PagesProviderInput`.
    ///     - generator: A valid generator.
    init(_ pages: PagerProviderInput<Offset>,
         generator: @escaping (_ offset: Offset.Offset) -> Pager<Offset.Offset, Stream>.Iteration) {
        self.init(pages.count, offset: pages.offset, generator: generator)
    }
}
