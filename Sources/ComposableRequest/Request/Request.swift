//
//  Request.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `struct` defining a composable `URLRequest`.
@dynamicMemberLookup
public struct Request: Hashable {
    /// Some valid `URLComponents`.
    public var components: URLComponents?
    /// A valid `HTTPMethod`.
    public var method: HTTPMethod
    /// Some valid header fields.
    public var header: [String: String]
    /// An optional body.
    public var body: Data?
    /// A valid `TimeInterval`.
    public var timeout: TimeInterval

    /// Init.
    ///
    /// - parameters:
    ///     - components: Some optional `URLComponents`.
    ///     - method: A valid `Method`. Defaults to `.default`.
    ///     - header: A dictionary of `String`s. Defaults to empty.
    ///     - body: Some optional `Data`. Defaults to `nil`.
    ///     - timeout: A valid `TimeInterval`. Defaults to `15`.
    public init(_ components: URLComponents?,
                method: HTTPMethod = .default,
                header: [String: String] = [:],
                body: Data? = nil,
                timeout: TimeInterval = 15) {
        self.components = components
        self.method = method
        self.header = header
        self.body = body
        self.timeout = timeout
    }

    /// Init.
    ///
    /// - parameters:
    ///     - url: An optional `URL`.
    ///     - query: A dictionary of `String`s. Defaults to empty.
    ///     - method: A valid `Method`. Defaults to `.default`.
    ///     - header: A dictionary of `String`s. Defaults to empty.
    ///     - body: Some optional `Data`. Defaults to `nil`.
    ///     - timeout: A valid `TimeInterval`. Defaults to `15`.
    public init(_ url: URL?,
                query: [String: String] = [:],
                method: HTTPMethod = .default,
                header: [String: String] = [:],
                body: Data? = nil,
                timeout: TimeInterval = 15) {
        var components = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        components?.queryItems = query.isEmpty ? nil : query.map { URLQueryItem(name: $0.key, value: $0.value) }
        self.init(components, method: method, header: header, body: body, timeout: timeout)
    }

    /// Init.
    ///
    /// - parameters:
    ///     - path: An optional `URL` path.
    ///     - query: A dictionary of `String`s. Defaults to empty.
    ///     - method: A valid `Method`. Defaults to `.default`.
    ///     - header: A dictionary of `String`s. Defaults to empty.
    ///     - body: Some optional `Data`. Defaults to `nil`.
    ///     - timeout: A valid `TimeInterval`. Defaults to `15`.
    /// - warning: An exception is thrown on invalid `path`s.
    public init(_ path: String?,
                query: [String: String] = [:],
                method: HTTPMethod = .default,
                header: [String: String] = [:],
                body: Data? = nil,
                timeout: TimeInterval = 15) {
        self.init(path.flatMap { URL(string: $0) },
                  query: query,
                  method: method,
                  header: header,
                  body: body,
                  timeout: timeout)
    }

    /// Init.
    ///
    /// - parameters:
    ///     - path: An optional `URL` path.
    ///     - query: A dictionary of `String`s. Defaults to empty.
    ///     - method: A valid `Method`. Defaults to `.default`.
    ///     - header: A dictionary of `String`s. Defaults to empty.
    ///     - body: Some optional `Data`. Defaults to `nil`.
    ///     - timeout: A valid `TimeInterval`. Defaults to `15`.
    public init(filePath path: String?,
                query: [String: String] = [:],
                method: HTTPMethod = .default,
                header: [String: String] = [:],
                body: Data? = nil,
                timeout: TimeInterval = 15) {
        self.init(path.flatMap { URL(fileURLWithPath: $0) },
                  query: query,
                  method: method,
                  header: header,
                  body: body,
                  timeout: timeout)
    }

    /// Compute the `URLRequest`.
    ///
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? {
        guard let url = components?.url else { return nil }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = header
        request.httpBody = body
        request.httpMethod = method == .default ? (body != nil ? "POST" : "GET") : method.rawValue
        request.timeoutInterval = timeout
        return request
    }
}

extension Request: Body, Header, Method, Path, Query, Timeout { }
