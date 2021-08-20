//
//  Receivables+Map.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/08/21.
//

import Foundation

public extension Receivables {
    /// A `struct` defining a requestable mapper.
    struct Map<Parent: Receivable, Success>: Receivable {
        /// The parent.
        public let parent: Parent
        /// The mapper.
        public let mapper: (Parent.Success) -> Success

        /// Init.
        ///
        /// - parameters:
        ///     - parent: A valid `Parent`.
        ///     - mapper: A valid mapper.
        /// - note: Prefer `parent.map(mapper)` instead.
        public init(parent: Parent, mapper: @escaping (Parent.Success) -> Success) {
            self.parent = parent
            self.mapper = mapper
        }
    }
}

public extension Receivable {
    /// Map to a different success.
    typealias Map<S> = Receivables.Map<Self, S>
}
