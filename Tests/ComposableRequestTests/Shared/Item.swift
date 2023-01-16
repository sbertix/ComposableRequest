//
//  Item.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 04/02/21.
//

import Foundation

import Requests
import Storages

/// A `struct` defining a `Storable`.
struct Item: Equatable, Codable, Storable {
    // swiftlint:disable force_unwrapping
    /// A default `Item`.
    static let `default` = Item(
        id: "item",
        cookies: [CodableHTTPCookie(properties: [.name: "ds_user_id",
                                                 .path: "test",
                                                 .value: "test",
                                                 .domain: "test"])!,
                  CodableHTTPCookie(properties: [.name: "csrftoken",
                                                 .path: "test",
                                                 .value: "test",
                                                 .domain: "test"])!,
                  CodableHTTPCookie(properties: [.name: "sessionid",
                                                 .path: "test",
                                                 .value: "test",
                                                 .domain: "test"])!]
    )
    // swiftlint:enable force_unwrapping

    /// The underlying label.
    let id: String
    /// The underlying user info.
    var cookies: [CodableHTTPCookie]
}
