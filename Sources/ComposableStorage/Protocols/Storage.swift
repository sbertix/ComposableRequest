//
//  Storage.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `protocol` defining an instance capable of caching `Storable`s.
///
/// The definition laverages `static` methods in order to "hide" their definition.
/// You should always conform to either `ThrowingStorage` or `NonThrowingStorage`, instead.
///
/// - warning: **Do not use directly**. Either conform to `ThrowingStorage` or `NonThrowingStorage`.
public protocol Storage {
    /// The associated `Storable`.
    ///
    /// - note: Every `Storage` can only store one type of item.
    associatedtype Item: Storable

    /// Return the first `Item` matching `label`, `nil` if none was found.
    ///
    /// - parameters:
    ///     - label: A valid `String`.
    ///     - storage: A valid `Storage`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    static func item(matching label: String, in storage: Self) throws -> Item?

    /// Return all stored `Item`s.
    ///
    /// - parameter storage: A valid `Storage`.
    /// - returns: An order collection of `Item`s.
    /// - throws: Some `Error`.
    static func items(in storage: Self) throws -> [Item]

    /// Store some `Item`, overwriting the ones matching its `label`.
    ///
    /// - parameters:
    ///     - item: A valid `Item`.
    ///     - storage: A valid `Storage`.
    /// - returns: `item`.
    /// - throws: Some `Error`.
    @discardableResult
    static func store(_ item: Item, in storage: Self) throws -> Item

    /// Return an `Item`, if found, then removes it from storage.
    ///
    /// - parameters:
    ///     - label: A valid `String`.
    ///     - storage: A valid `Storage`.
    /// - returns: An optional `Item`.
    /// - throws: Some `Error`.
    @discardableResult
    static func discard(_ label: String, in storage: Self) throws -> Item?

    /// Empty storage.
    ///
    /// - parameter storage: A valid `Storage`.
    /// - throws: Some `Error`.
    static func empty(_ storage: Self) throws
}
