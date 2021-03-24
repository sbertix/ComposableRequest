//
//  Logger+Level.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 22/03/21.
//

import Foundation

public extension Logger {
    /// An `enum`-like `struct` listing the different
    /// levels of logging.
    struct Level: OptionSet {
        /// The raw value.
        public let rawValue: Int

        /// Init.
        ///
        /// - parameter rawValue: A valid `Int`.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// HTTP request URL. Dispatched at request time.
        fileprivate static let requestURL = Level(rawValue: 1 << 0)
        /// HTTP method. Dispatched at request time.
        fileprivate static let requestMethod = Level(rawValue: 1 << 1)
        /// HTTP header fields. Dispatched at request time.
        fileprivate static let requestHeader = Level(rawValue: 1 << 2)
        /// HTTP body. Dispatched at request time.
        fileprivate static let requestBody = Level(rawValue: 1 << 3)

        /// HTTP response URL. Dispatched at response time.
        fileprivate static let responseURL = Level(rawValue: 1 << 10)
        /// HTTP response status code. Dispatched at response time.
        fileprivate static let responseStatusCode = Level(rawValue: 1 << 11)
        /// HTTP response error. Dispatched at response time.
        fileprivate static let responseError = Level(rawValue: 1 << 12)
        /// HTTP response header. Dispatched at response time.
        fileprivate static let responseHeader = Level(rawValue: 1 << 13)
        /// HTTP Response data. Dispatched at response time.
        fileprivate static let responseBody = Level(rawValue: 1 << 14)

        /// All.
        public static let all: Level = [Request.all, Response.all]
    }
}

public extension Logger.Level {
    /// A `module`-like `enum` defining request-based `Level`s.
    enum Request {
        /// HTTP request URL. Dispatched at request time.
        public static var url: Logger.Level { .requestURL }
        /// HTTP method. Dispatched at request time.
        public static var method: Logger.Level { .requestMethod }
        /// HTTP header fields. Dispatched at request time.
        public static var header: Logger.Level { .requestHeader }
        /// HTTP body. Dispatched at request time.
        public static var body: Logger.Level { .requestBody }

        /// Basic request.
        public static let basic: Logger.Level = [Request.url, Request.method]
        /// Full request.
        public static let all: Logger.Level = [Request.basic, Request.header, Request.body]
    }
}

public extension Logger.Level {
    /// A `module`-like `enum` defining response-based `Level`s.
    enum Response {
        /// HTTP response URL. Dispatched at response time.
        public static var url: Logger.Level { .responseURL }
        /// HTTP response status code. Dispatched at response time.
        public static var statusCode: Logger.Level { .responseStatusCode }
        /// HTTP response error. Dispatched at response time.
        public static var error: Logger.Level { .responseError }
        /// HTTP response header. Dispatched at response time.
        public static var header: Logger.Level { .responseHeader }
        /// HTTP Response data. Dispatched at response time.
        public static var body: Logger.Level { .responseBody }

        /// Basic response.
        public static let basic: Logger.Level = [Response.url, Response.statusCode, Response.error]
        /// Full response.
        public static let all: Logger.Level = [Response.basic, Response.header, Response.body]
    }
}
