//
//  Partial.swift
//  Core
//
//  Created by Stefano Bertagno on 17/11/22.
//

import Foundation

/// A `struct` defining an instance
/// wrapping some `URLSession` and
/// thus only requiring some `Input` to
/// be resolved.
public struct Partial<Parent: Endpoint> {
    /// The associated input type to generate request components.
    public typealias Input = Parent.Input
    /// The associated output type.
    public typealias Output = Parent.Output

    /// The original endpoint.
    private let parent: Parent
    /// The associated URL session.
    private weak var session: URLSession?
    
    /// Init.
    ///
    /// - parameters:
    ///     - parent: The parent endpoint.
    ///     - session: Some weak referenced `URLSession`.
    public init(parent: Parent, session: URLSession) {
        self.parent = parent
        self.session = session
    }
}
