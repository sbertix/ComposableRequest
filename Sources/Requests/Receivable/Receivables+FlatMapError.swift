//
//  Receivables+FlatMapError.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/08/21.
//

import Foundation

public extension Receivables {
    /// A `struct` defining a requestable flat mapper for failures.
    struct FlatMapError<Parent: Receivable> {
        /// The parent.
        public let parent: Parent
        /// The mapper.
        public let mapper: (Error) -> Result<Parent.Success, Error>

        /// Init.
        ///
        /// - parameters:
        ///     - parent: A valid `Parent`.
        ///     - mapper: A valid mapper.
        /// - note: Prefer `parent.map(mapper)` instead.
        public init(parent: Parent, mapper: @escaping (Error) -> Result<Parent.Success, Error>) {
            self.parent = parent
            self.mapper = mapper
        }
    }
}

extension Receivables.FlatMapError: Receivable {
    /// The associated success type.
    public typealias Success = Parent.Success
}

public extension Receivable {
    /// Map to a different success.
    typealias FlatMapError = Receivables.FlatMapError<Self>
}
