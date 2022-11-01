//
//  URLRequest+Endpoint.swift
//  Core
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Foundation

public extension URLRequest {
    /// Init a `URLRequest` from a valid `Endpoint`.
    ///
    /// - parameter endpoint: An `Endpoint`.
//    init?(_ endpoint: Endpoint) {
//        /// You always need at least a `Path`.
//        guard let path = endpoint.path?.value,
//              var components = URLComponents(string: path) else {
//            return nil
//        }
//        components.queryItems = endpoint.query?.value.map(URLQueryItem.init) ?? []
//        // If the URL is valid we can move forward.
//        guard let url = components.url else {
//            return nil
//        }
//        self.init(url: url)
//        self.allHTTPHeaderFields = endpoint.headers?.value
//        self.allowsCellularAccess = endpoint.cellular?.value ?? true
//        self.httpMethod = endpoint.method?.value == .default
//            ? (endpoint.body?.value != nil ? "POST" : "GET")
//            : endpoint.method?.value.rawValue
//        self.networkServiceType = endpoint.service?.value ?? .default
//        self.timeoutInterval = endpoint.timeout?.value ?? 60
//        
//        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
//            self.allowsConstrainedNetworkAccess = endpoint.constrained?.value ?? true
//            self.allowsExpensiveNetworkAccess = endpoint.expensive?.value ?? true
//        }
//    }
}
