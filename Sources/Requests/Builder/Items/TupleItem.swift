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
