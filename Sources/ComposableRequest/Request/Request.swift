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
    public typealias Response = Wrapper

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
extension Request: Composable, Parsable {
    public func replacing(method: Method) -> Request {
        return copy(self) { $0.method = method }
    }

    public func replacing(body data: Data?) -> Request {
        return copy(self) { $0.body = data }
    }

    public func replacing(header parameters: [String: String?]) -> Request {
        return copy(self) { $0.header = parameters.compactMapValues { $0 }}
    }

    public func replacing(query parameters: [String: String?]) -> Request {
        return copy(self) { $0.query = parameters.compactMapValues { $0 }}
    }

    public func appending(path pathComponent: String) -> Request {
        return copy(self) { $0.url.appendPathComponent(pathComponent) }
    }
}

// MARK: Requestable
extension Request: Requestable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? {
        // Create the components.
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        let queryItems = query.map { URLQueryItem(name: $0, value: $1) }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard var request = components.url.flatMap({ URLRequest(url: $0) }) else { return nil }
        request.allHTTPHeaderFields = header.isEmpty ? nil : header
        request.httpBody = body
        request.httpMethod = !method.rawValue.isEmpty ? method.rawValue : (body?.isEmpty == false ? "POST" : "GET")
        return request
    }
}
