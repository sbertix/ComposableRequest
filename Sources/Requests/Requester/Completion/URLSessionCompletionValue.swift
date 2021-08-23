//
//  URLSessionCompletionValue.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 23/08/21.
//

import Foundation

/// An `enum` listing all undelrying values.
public enum URLSessionCompletionValue {
    /// Invalid request.
    case invalidRequest(Request)
    /// Data task.
    case task(URLSessionDataTask)
}
