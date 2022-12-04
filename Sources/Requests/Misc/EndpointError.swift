//
//  EndpointError.swift
//  Requests
//
//  Created by Stefano Bertagno on 14/11/22.
//

import Foundation

/// An `enum` listing all available
/// `Endpoint`-related erros.
public enum EndpointError: Error {
    /// `Endpoint` `components` did
    /// not form a proper `URLRequest`.
    case invalidRequest
}
