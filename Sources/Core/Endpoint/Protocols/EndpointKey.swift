//
//  EndpointKey.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

public protocol EndpointKey {
    /// The associated endpoint identifier type.
    associatedtype EndpointID: Hashable
    /// The associated endpoint input type. Defaults to `Void`.
    associatedtype Input = Void
    
    /// The unique endpoint identifier.
    var endpointID: EndpointID { get }
}

/// When an instance conforms both to `EndpointKey`
/// and `RawRepresentable`, and its `RawValue` is
/// `Hashable`, infer `rawValue` to also represent
/// its `endpointID`.
public extension EndpointKey where Self: RawRepresentable, Self.RawValue == EndpointID {
    /// The unique endpoint identifier.
    var endpointID: EndpointID { rawValue }
}
