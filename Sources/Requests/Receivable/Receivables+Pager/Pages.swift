//
//  Pages.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 22/08/21.
//

import Foundation

/// A module-like `enum` listing all pager receivables support definitions.
public enum Pages<Offset> {
    /// A `struct` defining a pager's setup.
    public struct Input: PagerInput {
        /// The initial offset.
        public let offset: Offset
        /// The maximum number of pages.
        public let count: Int

        /// Init.
        ///
        /// - parameters:
        ///     - offset: A valid `Offset`.
        ///     - count: A valid `Int`.
        public init(offset: Offset, count: Int) {
            self.offset = offset
            self.count = count
        }
    }

    /// An `enum` listing a pager available instructions.
    public enum Instruction {
        /// Move to a new offset.
        case offset(Offset)
        /// Stop.
        case stop
    }
}
