//
//  Logger.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 14/05/2020.
//

import Foundation

/// A `struct` holding reference to the debug `Logger` configuration.
public struct Logger {
    /// An `enum` listing the level of logging.
    public struct Level: OptionSet {
        /// A valid `Int` raw value.
        public let rawValue: Int

        /// HTTP request URL. Dispatched at request time.
        public static let url = Level(rawValue: 1 << 0)
        /// HTTP method. Dispatched at request time.
        public static let method = Level(rawValue: 1 << 1)
        /// HTTP header fields. Dispatched at request time.
        public static let header = Level(rawValue: 1 << 2)
        /// HTTP body. Dispatched at request time.
        public static let body = Level(rawValue: 1 << 3)

        /// HTTP response URL. Dispatched at response time.
        public static let responseURL = Level(rawValue: 1 << 10)
        /// HTTP response status code. Dispatched at response time.
        public static let responseStatusCode = Level(rawValue: 1 << 11)
        /// HTTP response error. Dispatched at response time.
        public static let responseError = Level(rawValue: 1 << 12)
        /// HTTP response header. Dispatched at response time.
        public static let responseHeader = Level(rawValue: 1 << 13)
        /// HTTP Response data. Dispatched at response time.
        public static let responseBody = Level(rawValue: 1 << 14)

        /// None.
        public static let none: Level = []
        /// Basic.
        public static let basic: Level = [.url, .method]
        /// Full requesst.
        public static let request: Level = [.url, .method, .header, .body]
        /// Full response.
        public static let response: Level = [.responseURL, .responseStatusCode, .responseError, .responseHeader, .responseBody]
        /// Full.
        public static let full: Level = [.request, .response]

        /// Init.
        ///
        /// - parameter rawValue: A valid `Int`.
        public init(rawValue: Int) { self.rawValue = rawValue }

        // MARK: Log

        /// Log request.
        ///
        /// - parameter request: A valid `URLRequest`.
        internal func log(request: URLRequest) {
            let url = contains(.url) ? request.url.flatMap { "\tURL: "+$0.absoluteString } : nil
            let method = contains(.method) ? request.httpMethod.flatMap { "\tMethod: "+$0 } : nil
            let header = contains(.header) ? request.allHTTPHeaderFields.flatMap { "\tHeader: "+$0.description } : nil
            let body = contains(.body)
                ? request.httpBody
                    .flatMap { String(data: $0, encoding: .utf8) }
                    .flatMap { "\tBody: "+$0 }
                : nil
            // Compose.
            guard url != nil || method != nil || header != nil || body != nil else { return }
            DispatchQueue.main.async {
                print((["Request:"]+[url, method, header, body].compactMap { $0 }).joined(separator: "\n"))
            }
        }

        /// Log response.
        ///
        /// - parameter result: A valid `Result`.
        internal func log(_ result: Result<Request.Response, Error>) {
            do {
                let item = try result.get()
                let url = contains(.responseURL) ? item.response.url.flatMap { "\tURL: "+$0.absoluteString } : nil
                let statusCode = contains(.responseStatusCode) ? (item.response as? HTTPURLResponse).flatMap { "\tURL: \($0.statusCode)" } : nil
                let header = contains(.responseHeader)
                    ? ((item.response as? HTTPURLResponse)?.allHeaderFields as? [String: String]).flatMap { "\tHeader: "+$0.debugDescription }
                    : nil
                let body = contains(.responseBody)
                    ? "\tBody: "+(String(data: item.data, encoding: .utf8) ?? "<parser error>")
                    : nil
                // Compose.
                guard url != nil || statusCode != nil || header != nil || body != nil else { return }
                DispatchQueue.main.async {
                    print((["Response:", url, statusCode, header, body].compactMap { $0 }.joined(separator: "\n")))
                }
            } catch {
                let exception = contains(.responseError) ? error.localizedDescription : nil
                // Compose.
                guard exception != nil else { return }
                DispatchQueue.main.async {
                    print([["Response", exception].compactMap { $0 }.joined(separator: "\n")])
                }
            }
        }
    }

    /// The current level. Defaults to `.none`.
    public static var `default`: Level = .none
}
