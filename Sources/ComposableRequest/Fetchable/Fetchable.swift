//
//  Fetchable.swift
//  ComposableReuqest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

import Foundation

/// A `protocol` defining the initializer of a `Requester.Task`.
public protocol Fetchable {
    /// An associated `Request`.
    associatedtype Request: Requestable
    /// An associated `Response`.
    associatedtype Response
    
    /// The underlying `Request`.
    var request: Request { get }
}
