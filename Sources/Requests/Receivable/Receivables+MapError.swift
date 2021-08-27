//
//  Receivables+MapError.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/08/21.
//

import Foundation

public extension Receivables {
    /// A `struct` defining a requestable mapper for failures.
    ///
    /// - note:
    ///     All `Requestable`s are still required to fail with `Error`,
    ///     but this doesn't mean you shouldn't be able to process it.
    struct MapError<Parent: Receivable> {
        /// The parent.
        public let parent: Parent
        /// The mapper.
        public let mapper: (Error) -> Error

        /// Init.
        ///
        /// - parameters:
        ///     - parent: A valid `Parent`.
        ///     - mapper: A valid mapper.
        /// - note: Prefer `parent.map(mapper)` instead.
        public init(parent: Parent, mapper: @escaping (Error) -> Error) {
            self.parent = parent
            self.mapper = mapper
        }
    }
}

extension Receivables.MapError: Receivable {
    /// The associated success type.
    public typealias Success = Parent.Success
}

public extension Receivable {
    /// Map to a different success.
    typealias MapError = Receivables.MapError<Self>
}
