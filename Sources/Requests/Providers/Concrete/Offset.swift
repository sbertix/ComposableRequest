//
//  Offset.swift
//  Requests
//
//  Created by Stefano Bertagno on 17/11/22.
//

import Foundation

public extension Providers {
    /// A `struct` defining an instance
    /// abstracting a page reference,
    /// identified by some bookmark.
    struct Offset<Offset, Page>: OffsetProvider {
        /// The output generator.
        private let content: (Offset) -> Page
        
        /// Init.
        ///
        /// - parameter content: The output factory.
        public init(_ content: @escaping (Offset) -> Page) {
            self.content = content
        }
        
        /// Compose the page.
        ///
        /// - parameter offset: Some `Offset`.
        /// - returns: Some `Page`.
        public func offset(_ offset: Offset) -> Page {
            content(offset)
        }
    }
}
