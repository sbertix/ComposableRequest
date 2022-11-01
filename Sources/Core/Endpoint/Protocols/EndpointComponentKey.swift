//
//  EndpointComponentKey.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

/// An `enum` listing all available
/// endpoint components.
public enum EndpointComponentKey: Hashable {
    case method
    case path
    case query
    case headers
    case body
    
    case service
    case cellular
    case timeout
    case constrained
    case expensive
}
