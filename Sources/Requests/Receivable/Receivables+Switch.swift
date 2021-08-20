//
//  Receivables+Switch.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

public extension Receivables {
    /// A `struct` defining a requestable switcher.
    struct Switch<Parent: Receivable, Child: Receivable> {
        /// The parent.
        public let parent: Parent
        /// The child generator.
        public let generator: (Parent.Success) -> Child

        /// Init.
        ///
        /// - parameters:
        ///     - parent: A valid `Parent`.
        ///     - generator: A valid child generator.
        /// - note: Prefer `parent.switch(generator)` instead.
        public init(parent: Parent, generator: @escaping (Parent.Success) -> Child) {
            self.parent = parent
            self.generator = generator
        }
    }
}

extension Receivables.Switch: Receivable {
    /// The associated success type.
    public typealias Success = Child.Success
}

public extension Receivable {
    /// Map to a different success.
    typealias Switch<C> = Receivables.Switch<Self, C> where C: Receivable
}
