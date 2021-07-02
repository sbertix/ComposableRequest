//
//  Request.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 02/07/21.
//

import Foundation

/// A `struct` defining a declerateive request stream.
public struct Request {
    /// Some valid `URLComponents`.
    public let components: URLComponents?
    /// A valid `HTTPMethod`. Defaults to `.default`.
    public let method: HTTPMethod
    /// Some valid header fields. Defaults to an empty one.
    public let header: [String: String]
    /// An optional body. Defaults to `nil`.
    public let body: Data?
    /// A valid `TimeInterval`. Defaults to `15`.
    public let timeout: TimeInterval

    /// Init.
    ///
    /// - parameter request: A concreate instance of `URLRequestRepresentable`.
    init<R: URLRequestRepresentable>(_ request: R) {
        let request = R.request(from: request)
        self.components = request?.url.flatMap { .init(url: $0, resolvingAgainstBaseURL: false) }
        self.method = request?.httpMethod.flatMap(HTTPMethod.init) ?? .default
        self.header = request?.allHTTPHeaderFields ?? [:]
        self.body = request?.httpBody
        self.timeout = request?.timeoutInterval ?? 15
    }

    /// Init.
    ///
    /// - parameters:
    ///     - components: A concrete instance of `URLComponentsRepresentable`.
    ///     - method: A valid `HTTPMethod`. Defaults to `.default`.
    ///     - header: A valid `String` dictionary. Defaults to an empty one.
    ///     - body: Some optional `Data`. Defaults to `nil`.
    ///     - timeout: A valid `TimeInterval`. Defaults to `15`.
    init<C: URLComponentsRepresentable>(_ components: C,
                                        method: HTTPMethod = .default,
                                        header: [String: String] = [:],
                                        body: Data? = nil,
                                        timeout: TimeInterval = 15) {
        self.components = C.components(from: components)
        self.method = method
        self.header = header
        self.body = body
        self.timeout = timeout
    }

    /// Iint.
    ///
    /// - parameters:
    ///     - url: A concrete instance of `URLRepresentable`.
    ///     - query: A valid `String` dictionary. Defaults to an empty one.
    ///     - method: A valid `HTTPMethod`. Defaults to `.default`.
    ///     - header: A valid `String` dictionary. Defaults to an empty one.
    ///     - body: Some optional `Data`. Defaults to `nil`.
    ///     - timeout: A valid `TimeInterval`. Defaults to `15`.
    init<U: URLRepresentable>(_ url: U,
                              query: [String: String] = [:],
                              method: HTTPMethod = .default,
                              header: [String: String] = [:],
                              body: Data? = nil,
                              timeout: TimeInterval = 15) {
        self.components = U.url(from: url).flatMap {
            var components = URLComponents(url: $0, resolvingAgainstBaseURL: false)
            components?.queryItems = query.isEmpty
                ? nil
                : query.map { URLQueryItem(name: $0.key, value: $0.value) }
            return components
        }
        self.method = method
        self.header = header
        self.body = body
        self.timeout = timeout
    }
}

extension Request: URLRequestRepresentable {
    /// Compose an optional `URLRequest`.
    ///
    /// - note: This is implemented as a `static` method to hide its declaration.
    /// - parameter convertible: A valid `Self`.
    /// - returns: An optional `URLRequest`.
    public static func request(from convertible: Self) -> URLRequest? {
        guard let url = convertible.components?.url else { return nil }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = convertible.header
        request.httpBody = convertible.body
        request.httpMethod = convertible.method == .default
            ? (convertible.body != nil ? "POST" : "GET")
            : convertible.method.rawValue
        request.timeoutInterval = convertible.timeout
        return request
    }
}

extension Request: Body, Header, Method, Query, Timeout {
    /// Copy `self` and replace its `body`.
    ///
    /// - parameter body: Some optional `Data`.
    /// - returns: A valid `Self`.
    public func body(_ body: Data?) -> Self {
        .init(components, method: method, header: header, body: body, timeout: timeout)
    }

    /// Copy `self` and replace its `header`.
    ///
    /// - parameter header: A valid`String` dictionary.
    /// - returns: A valid `Self`.
    public func header(_ header: [String: String]) -> Self {
        .init(components, method: method, header: header, body: body, timeout: timeout)
    }

    /// Copy `self` and replace its `method`.
    ///
    /// - parameter mody: A valid `HTTPMethod`.
    /// - returns: A valid `Self`.
    public func method(_ method: HTTPMethod) -> Self {
        .init(components, method: method, header: header, body: body, timeout: timeout)
    }

    /// Copy `self` and replace its `components`.
    ///
    /// - parameter components: An optional `URLComponents`.
    /// - returns: A valid `Self`.
    public func components(_ components: URLComponents?) -> Self {
        .init(components, method: method, header: header, body: body, timeout: timeout)
    }

    /// Copy `self` and replace its `timeout`.
    ///
    /// - parameter seconds: A valid `TimeInterval`.
    /// - returns: A valid `Self`.
    public func timeout(after seconds: TimeInterval) -> Self {
        .init(components, method: method, header: header, body: body, timeout: seconds)
    }
}
