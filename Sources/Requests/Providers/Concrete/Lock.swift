//
//  Lock.swift
//  Requests
//
//  Created by Stefano Bertagno on 17/11/22.
//

import Foundation

public extension Providers {
    /// A `struct` defining an instance
    /// abstracting a lock, a padlock, requiring
    /// some key to be opened.
    struct Lock<Key, Secret>: LockProvider {
        /// The output generator.
        private let content: (Key) -> Secret
        
        /// Init.
        ///
        /// - parameter content: The output factory.
        public init(_ content: @escaping (Key) -> Secret) {
            self.content = content
        }
        
        /// Unlock the output.
        ///
        /// - parameter key: Some `Key`.
        /// - returns: Some `Secret`.
        public func unlock(with key: Key) -> Secret {
            content(key)
        }
    }
}
