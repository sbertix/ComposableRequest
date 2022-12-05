//
//  TupleItem.swift
//  Requests
//
//  Created by Stefano Bertagno on 04/12/22.
//

import Foundation

/// A `struct` used to hold together
/// partial blocks inside the endpoint builder.
///
/// - note:
///     Some sort of ordering should be
///     guaranteed by the builder.
public struct TupleItem<F, L> {
    /// The first item.
    var first: F
    /// The last item.
    var last: L
}

/// A `struct` used to hold together
/// partial blocks inside the endpoint builder.
///
/// - note:
///     Some sort of ordering should be
///     guaranteed by the builder.
public struct Tuple3Item<F, M, L> {
    /// The first item.
    var first: F
    /// The middle item.
    var middle: M
    /// The last item.
    var last: L
}

/// The default `Tuple3Item`.
public typealias TupleEndpoint<O> = Tuple3Item<Path, Components, Response<DefaultResponse, O>>
