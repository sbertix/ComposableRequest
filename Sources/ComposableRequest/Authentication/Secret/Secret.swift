//
//  Secret.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 16/03/2020.
//

import Foundation

/// A `protocol` describing an item providing for authentication.
public protocol Secret {
    /// A valid `Dictionary` of `String`s representing header fields.
    var headerFields: [String: String] { get }
    /// A valid `Dictionary` of `String`s representing body parameters.
    var body: [String: String] { get }
}
