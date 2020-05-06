//
//  Request.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `struct` representing a composable `URLRequest`.
@dynamicMemberLookup
public struct Request: Hashable {
    /// `ComposableRequest` defaults to `Response`.
    public typealias Response = ComposableRequest.Response
    
    /// A valid `Method`.
    public var method: Method
    /// A valid `URL`.
    public var url: URL
    /// A valid `Dictionary` of `String`s.
    public var query: [String: String]
    /// A valid `Dictionary` of `String`s referencing the request header fields.
    public var header: [String: String]
    /// A valid `Body`.
    public var body: Data?

    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - url: A valid `URL`.
    ///     - method: A valid `Method`. Defaults to `.default`.
    ///     - query: A valid `Dictionary` of `String`s. Defaults to `[:]`.
    ///     - header: A valid `Dictionary` of `String`s. Defaults to `[:]`.
    ///     - body: A valid optional `Data`. Defaults to `nil`.
    public init(_ url: URL, method: Method = .default, query: [String: String] = [:], body: Data? = nil, header: [String: String] = [:]) {
        self.url = url
        self.query = query
        self.method = method
        self.body = body
        self.header = header
    }

    /// Init.
    /// - parameters:
    ///     - string: A valid `URL` string.
    ///     - method: A valid `Method`. Defaults to `.default`.
    ///     - query: A valid `Dictionary` of `String`s. Defaults to `[:]`.
    ///     - header: A valid `Dictionary` of `String`s. Defaults to `[:]`.
    ///     - body: A valid optional `Data`. Defaults to `nil`.
    public init(_ string: String, method: Method = .default, query: [String: String] = [:], body: Data? = nil, header: [String: String] = [:]) {
        self.url = URL(string: string)!
        self.query = query
        self.method = method
        self.body = body
        self.header = header
    }
}

// MARK: Composable
/// `Composable` conformacies.
extension Request: Composable {
    public func replace(method: Method) -> Request {
        return copy(self) { $0.method = method }
    }
    
    public func replace(body data: Data?) -> Request {
        return copy(self) { $0.body = data }
    }
    
    public func append(header parameters: [String : String?]) -> Request {
        return copy(self) { this in parameters.forEach { this.header[$0.key] = $0.value }}
    }
    
    public func replace(header parameters: [String : String?]) -> Request {
        return copy(self) { $0.header = parameters.compactMapValues { $0 }}
    }
    
    public func append(path pathComponent: String) -> Request {
        return copy(self) { $0.url.appendPathComponent(pathComponent) }
    }
    
    public func append<C>(query items: C) -> Request where C : Collection, C.Element == URLQueryItem {
        return copy(self) { this in items.forEach { this.query[$0.name] = $0.value }}
    }
    
    public func replace<C>(query items: C) -> Request where C : Collection, C.Element == URLQueryItem {
        return copy(self) { this in this.query = [:]; items.forEach { this.query[$0.name] = $0.value }}
    }
}

// MARK: Requestable
extension Request: Fetchable {    
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? {
        // Create the components.
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = query.map { URLQueryItem(name: $0, value: $1) }
        guard var request = components.url.flatMap({ URLRequest(url: $0) }) else { return nil }
        request.allHTTPHeaderFields = header
        request.httpBody = body
        request.httpMethod = method.rawValue != "" ? method.rawValue : (body?.isEmpty == false ? "POST" : "GET")
        return request
    }
}
