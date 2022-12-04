//
//  CharacterSet.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 28/06/2020.
//

import Foundation

/// An `extension` for `CharacterSet`.
public extension CharacterSet {
    /// A `.urlQueryAllowed` subset, used for body requests.
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        // Compose and return.
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
