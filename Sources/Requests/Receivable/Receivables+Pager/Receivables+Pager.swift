//
//  Receivables+Pager.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 22/08/21.
//

import Foundation

public extension Receivables {
    /// A `struct` defining a requestable pager.
    ///
    /// - note:
    ///     When it dispatches from a non-`Paginatable`
    ///     `Requester` only the initial result is ever returned.
    struct Pager<Offset, Child: Receivable> {
        /// The initial offset.
        public let offset: Offset
        /// The maximum pages to fetch.
        public let count: Int
        /// The child generator.
        public let generator: (Offset) -> Child
        /// The next offset generator.
        public let nextOffset: (Child.Success) -> Pages<Offset>.Instruction

        /// Init.
        ///
        /// - parameters:
        ///     - offset: A valid `Offset`.
        ///     - count: A valid `Int`.
        ///     - generator: A valid child generator.
        ///     - nextOffset: A valid next offset generator.
        public init(offset: Offset,
                    count: Int,
                    generator: @escaping (Offset) -> Child,
                    nextOffset: @escaping (Child.Success) -> Pages<Offset>.Instruction) {
            self.offset = offset
            self.count = count
            self.generator = generator
            self.nextOffset = nextOffset
        }

        /// Init.
        ///
        /// - parameters:
        ///     - input: A concrete instance of `PagerInput`.
        ///     - generator: A valid child generator.
        ///     - nextOffset: A valid next offset generator.
        public init<P: PagerInput>(_ input: P,
                                   generator: @escaping (Offset) -> Child,
                                   nextOffset: @escaping (Child.Success) -> Pages<Offset>.Instruction)
        where P.Offset == Offset {
            self.init(offset: input.offset,
                      count: input.count,
                      generator: generator,
                      nextOffset: nextOffset)
        }
    }
}

extension Receivables.Pager: Receivable {
    /// The associated success type.
    public typealias Success = Child.Success
}

public extension Receivable {
    /// A typealias for pager generation.
    typealias Pager<O> = Receivables.Pager<O, Self>
}
