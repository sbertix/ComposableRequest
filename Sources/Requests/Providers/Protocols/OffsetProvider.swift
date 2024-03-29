//
//  OffsetProvider.swift
//  Requests
//
//  Created by Stefano Bertagno on 17/11/22.
//

import Foundation

/// A `protocol` defining a provider abstracting
/// a page reference, identified by some bookmark.
public protocol OffsetProvider<Offset, Page>: Provider where Input == Offset, Output == Page {
    /// The associated offset type.
    associatedtype Offset
    /// The associated page type.
    associatedtype Page

    /// Compose the page.
    ///
    /// - parameter offset: Some `Offset`.
    /// - returns: Some `Page`.
    func start(at offset: Offset) -> Page
}

public extension OffsetProvider {
    /// Generate an output.
    ///
    /// - parameter input: Some `Input`.
    /// - returns: Some `Output`.
    @_spi(Private)
    func _output(from input: Input) -> Output {
        start(at: input)
    }
}

public extension OffsetProvider {
    /// Compose the page, with no offset.
    ///
    /// - returns: Some `Page`.
    func start() -> Page where Offset == Void {
        start(at: ())
    }

    /// Compose the page, with no offset.
    ///
    /// - returns: Some `Page`.
    func start<T>() -> Page where T? == Offset {
        start(at: nil)
    }
}
