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
    /// `AsyncThrowingStream` never
    /// emitted.
    case emptyStream
    /// Invalid cached `Publisher` type.
    case invalidPublisherType
    /// `Endpoint` `components` did
    /// not form a proper `URLRequest`.
    case invalidRequest
}
