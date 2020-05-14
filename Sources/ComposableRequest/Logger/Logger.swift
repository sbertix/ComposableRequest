//
//  Logger.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 14/05/2020.
//

import Foundation

/// A `struct` holding reference to the debug `Logger` configuration.
public struct Logger {
    /// An `enum` listing the level of logging.
    public enum Level: Int, Comparable {
        /// No logging.
        case none
        /// Loggin requests only.
        case requests
        
        /// Compare levels.
        /// - parameters:
        ///     - lhs: A valid `Level`.
        ///     - rhs: A valid `Level`.
        /// - returns: `true` if `lhs` has lower priority than `rhs`, `false` otherwise.
        public static func < (lhs: Logger.Level, rhs: Logger.Level) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    /// The current level. Defaults to `.none`.
    public static var level: Level = .none
}
