//
//  DataExtension.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 03/11/20.
//

import Foundation

public extension Data {
    /// Decode a dictionary of `String`s, like in `URLRequest` bodies, or `nil` if not doable.
    var parameters: [String: String]? {
        return String(data: self, encoding: .utf8)?
            .components(separatedBy: "&")
            .reduce(into: [String: String]()) { dictionary, element in
                let components = element.components(separatedBy: "=")
                guard components.count == 2 else { return }
                dictionary[components[0]] = components[1].removingPercentEncoding
            }
    }
}

extension Dictionary where Key == String, Value == String {
    /// Encode some `Data`, from the given parameters.
    var encoded: Data? {
        let parameters = self.compactMapValues { $0.escaped }.map { "\($0.key)=\($0.value)" }
        guard !parameters.isEmpty else { return nil }
        return parameters.joined(separator: "&").data(using: .utf8)
    }
}
