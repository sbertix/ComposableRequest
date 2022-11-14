//
//  Offset.swift
//  Core
//
//  Created by Stefano Bertagno on 17/11/22.
//

#if canImport(Logging)
import Logging
#endif

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
            #if canImport(Logging)
            // Using `Lock`s with `Endpoint` `Page`s
            // is no longer advised: rely on `Endpoint`
            // `Input` directly.
            guard Page is Endpoint else { return }
            os_log(.info, "Please prefer `Partial` `Endpoint`s to custom `Provider`s.")
            #endif
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
