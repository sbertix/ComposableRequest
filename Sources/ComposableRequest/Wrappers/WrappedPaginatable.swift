//
//  WrappedPaginatable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/04/2020.
//

import Foundation

/// A `protocol` representing an item holding a reference to a `Paginatable`.
public protocol WrappedPaginatable: Paginatable {
    /// The underlying `Paginatable`.
    associatedtype Paginatable: ComposableRequest.Paginatable where Paginatable.Response == Response

    /// An underlying `Paginatable`.
    var paginatable: Paginatable { get set }
}

public extension WrappedPaginatable {
    /// The `name` of the `URLQueryItem` used for paginating.
    var key: String {
        get { return paginatable.key }
        set { paginatable.key = newValue }
    }

    /// The inital `value` of the `URLQueryItem` used for paginating.
    var initial: String? {
        get { return paginatable.initial }
        set { paginatable.initial = newValue }
    }

    /// The next `value` of the `URLQueryItem` user for paginating, based on the last `Response`.
    var next: (Result<Response, Error>) -> String? {
        get { return paginatable.next }
        set { paginatable.next = newValue }
    }

    /// Additional parameters for the header fields, based on the last `Response`.
    var nextHeader: ((Result<Response, Error>) -> [String: String?]?)? {
        get { return paginatable.nextHeader }
        set { paginatable.nextHeader = newValue }
    }

    /// Additional parameters for the body, based on the last `Response`.
    var nextBody: ((Result<Response, Error>) -> [String: String?]?)? {
        get { return paginatable.nextBody }
        set { paginatable.nextBody = newValue }
    }
}
