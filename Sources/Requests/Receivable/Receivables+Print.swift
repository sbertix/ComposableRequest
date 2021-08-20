//
//  Receivables+Print.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

public extension Receivables {
    /// A `struct` defining a requestable printer.
    struct Print<Parent: Receivable> {
        /// The parent.
        public let parent: Parent

        /// Init.
        ///
        /// - parameter parent: A valid `Parent`.
        /// - note: Prefer `parent.print()` instead.
        public init(parent: Parent) {
            self.parent = parent
        }
    }
}

extension Receivables.Print: Receivable {
    /// The associated success type.
    public typealias Success = Parent.Success
}

public extension Receivable {
    /// Map to a different success.
    typealias Print = Receivables.Print<Self>
}
