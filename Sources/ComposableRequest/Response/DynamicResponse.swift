//
//  DynamicResponse.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 15/05/2020.
//

import Foundation

/// A `protocol` defining a dynamic response.
public protocol DynamicResponse {
    /// An optional `Array` of `Response`s.
    func array() -> [Self]?

    /// An optional `Bool`.
    func bool() -> Bool?

    /// An optional `Date`.
    func date() -> Date?

    /// An optional `Dictionary` of `Response`s.
    func dictionary() -> [String: Self]?

    /// An optional `Double`.
    func double() -> Double?

    /// An optional `Int`.
    func int() -> Int?

    /// An optional `String`.
    func string() -> String?

    /// An optional `URL`.
    func url() -> URL?

    /// Interrogate `.dictionary`.
    /// - parameter member: A valid `Dictionary` key.
    subscript(dynamicMember member: String) -> Self { get }

    /// Interrogate `.dictionary`.
    /// - parameter key: A valid `Dictionary` key.
    subscript(key: String) -> Self { get }

    /// Access the `index`-th item in `.array`.
    /// - parameter index: A valid `Int`.
    subscript(index: Int) -> Self { get }
}
