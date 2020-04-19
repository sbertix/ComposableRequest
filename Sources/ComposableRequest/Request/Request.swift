//
//  Request.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `struct` representing a composable `URLRequest`.
@dynamicMemberLookup
public struct Request: Hashable, Lockable, Singular {
    /// `ComposableRequest` defaults to `Response`.
    public typealias Response = ComposableRequest.Response

    /// An `enum` representing a `URLRequest` possible `httpBody`-s.
    public enum Body: Hashable {
        /// A `Dictionary` of `String`s.
        case parameters([String: String])
        /// A `Data` value.
        case data(Data)

        /// Encode to `Data`.
        internal var data: Data? {
            switch self {
            case .data(let data): return data
            case .parameters(let parameters):
                return parameters.map { [$0.key, "=", $0.value].joined() }
                    .joined(separator: "&")
                    .data(using: .utf8)
            }
        }
    }

    /// An `enum` representing a `URLRequest` allowed `httpMethod`s.
    public enum Method: Hashable {
        /// `GET` when no `body` is set, `POST` otherwise.
        case `default`
        /// `GET`.
        case get
        /// `POST`
        case post

        /// A `String` based method, according to `.httpBody`.
        internal func resolve(using body: Data?) -> String {
            switch self {
            case .get: return "GET"
            case .post: return "POST"
            case .default:
                return body?.isEmpty == false
                    ? "POST"
                    : "GET"
            }
        }
    }

    /// A valid `URLComponents` item.
    public var components: URLComponents
    /// A valid `Method`.
    public var method: Method
    /// A valid `Body`.
    public var body: Body?
    /// A valid `Dictionary` of `String`s referencing the request header fields.
    public var header: [String: String]

    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - url: A valid `URL`.
    ///     - method: A valid `Method`. Defaults to `.default`.
    ///     - body: A valid optional `Body`. Defaults to `nil`.
    ///     - header: A valid `Dictionary` of `String`s. Defaults to `[:]`.
    public init(_ url: URL, method: Method = .default, body: Body? = nil, header: [String: String] = [:]) {
        self.components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        self.method = method
        self.body = body
        self.header = header
    }

    /// Init.
    /// - parameters:
    ///     - string: A valid `URL` string.
    ///     - method: A valid `Method`. Defaults to `.default`.
    ///     - body: A valid optional `Body`. Defaults to `nil`.
    ///     - header: A valid `Dictionary` of `String`s. Defaults to `[:]`.
    public init(_ string: String, method: Method = .default, body: Body? = nil, header: [String: String] = [:]) {
        self.init(URL(string: string)!, method: method, body: body, header: header)
    }
}

// MARK: Composable
/// `Composable` conformacies.
extension Request: Composable {
    /// Append `pathComponent`.
    /// - parameter pathComponent: A `String` representing a path component.
    public func append(_ pathComponent: String) -> Request {
        return copy(self) {
            $0.components = $0.components.url
                .flatMap {
                    $0.appendingPathComponent(pathComponent.trimmingCharacters(in: .init(charactersIn: "/"))+"/")
                }
                .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) } ?? $0.components
        }
    }

    /// Append to `queryItems`. Empty `queryItems` if `nil`.
    /// - parameter method: A `Request.Method` value.
    public func query(_ items: [String: String?]?) -> Request {
        return copy(self) {
            guard let items = items else {
                $0.components.queryItems = nil
                return
            }
            var dictionary = Dictionary(uniqueKeysWithValues:
                $0.components.queryItems?.compactMap { item in
                    item.value.flatMap { (item.name, $0) }
                } ?? []
            )
            items.forEach {
                guard !$0.key.isEmpty else { return }
                dictionary[$0.key] = $0.value
            }
            $0.components.queryItems = dictionary.isEmpty
                ? nil
                : dictionary.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
    }

    /// Set `method`.
    /// - parameter method: A `Request.Method` value.
    public func method(_ method: Request.Method) -> Request {
        return copy(self) { $0.method = method }
    }

    /// Set `body`.
    /// - parameter body: A valid `Request.Body`.
    public func body(_ body: Request.Body) -> Request {
        return copy(self) { $0.body = body }
    }

    /// Append to `Request.Body.parameters`. Empty `body` if `nil`.
    /// - parameter parameters: An optional `Dictionary` of  option`String`s.
    public func body(_ parameters: [String: String?]?) -> Request {
        return copy(self) {
            guard let body = $0.body, case .parameters(var dictionary) = body else {
                $0.body = parameters.flatMap { .parameters($0.compactMapValues { $0 }) }
                return
            }
            parameters?.forEach {
                guard !$0.key.isEmpty else { return }
                dictionary[$0.key] = $0.value
            }
            $0.body = dictionary.isEmpty ? nil : .parameters(dictionary)
        }
    }

    /// Append to `header`. Empty `header` if `nil`.
    /// - parameter fields: An optional `Dictionary` of  option`String`s.
    public func header(_ fields: [String: String?]?) -> Request {
        return copy(self) {
            var dictionary = $0.header
            fields?.forEach {
                guard !$0.key.isEmpty else { return }
                dictionary[$0.key] = $0.value
            }
            $0.header = dictionary
        }
    }
}

// MARK: Requestable
extension Request: Requestable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? {
        return components.url.flatMap {
            var request = URLRequest(url: $0)
            request.httpBody = body?.data
            request.httpMethod = method.resolve(using: request.httpBody)
            request.allHTTPHeaderFields = header
            return request
        }
    }
}
