//
//  Item.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 04/02/21.
//

import Foundation

import ComposableRequest
import ComposableStorage

/// A `struct` defining a `Storable`.
struct Item: Equatable, Codable, Storable {
    /// The underlying label.
    let label: String
    /// The underlying user info.
    let cookies: [CodableHTTPCookie]
    
    /// A default `Item`.
    static let `default` = Item(label: "item",
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
                                                                         .domain: "test"])!])
}
