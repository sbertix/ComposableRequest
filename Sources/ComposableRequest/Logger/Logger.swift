//
//  Logger.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 14/05/2020.
//

import Foundation

/// A `struct` defining an instance handling `Request` logs.
public struct Logger {
    /// A shared instance of `Logger`, printing logs
    /// directly to the console, and `nil` level.
    ///
    /// Update this according to your needs.
    public static var `default`: Logger = .init(level: nil)

    /// The logger level.
    private let level: Level?
    /// The underlying handler.
    private let handler: (String) -> Void

    /// Init.
    ///
    /// - parameters:
    ///     - level: An optional `Level`.
    ///     - handler: A valid log handler. Defaults to `nil`, printing to the console.
    public init(level: Level?, handler: ((String) -> Void)? = nil) {
        self.level = level
        self.handler = handler ?? { log in DispatchQueue.main.async { print(log) }}
    }

    /// Log the request.
    ///
    /// - parameter request: A valid `URLRequest`.
    public func log(_ request: URLRequest) {
        guard let level = level else { return }
        // Check levels.
        let url = level.contains(Logger.Level.Request.url)
            ? request.url.flatMap { "\tURL: "+$0.absoluteString }
            : nil
        let method = level.contains(Logger.Level.Request.method)
            ? request.httpMethod.flatMap { "\tMethod: "+$0 }
            : nil
        let header = level.contains(Logger.Level.Request.header)
            ? request.allHTTPHeaderFields.flatMap { "\tHeader: "+$0.description }
            : nil
        let body = level.contains(Logger.Level.Request.body)
            ? request.httpBody
                .flatMap { String(data: $0, encoding: .utf8) }
                .flatMap { "\tBody: "+$0 }
            : nil
        // Compose.
        let components = [url, method, header, body].compactMap { $0 }
        guard !components.isEmpty else { return }
        let log = (["Request:"]+components).joined(separator: "\n")
        handler(log)
    }

    /// Log the response.
    ///
    /// - parameter result: A valid `Result`.
    public func log(_ result: Result<Request.Response, Error>) {
        guard let level = level else { return }
        // Check levels.
        let item = try? result.get()
        let url = level.contains(Logger.Level.Response.url)
            ? item?.response.url.flatMap { "\tURL: "+$0.absoluteString }
            : nil
        let response = item?.response as? HTTPURLResponse
        let statusCode = level.contains(Logger.Level.Response.statusCode)
            ? response.flatMap { "\tURL: \($0.statusCode)" }
            : nil
        let header = level.contains(Logger.Level.Response.header)
            ? (response?.allHeaderFields as? [String: String]).flatMap { "\tHeader: "+$0.debugDescription }
            : nil
        let body = level.contains(Logger.Level.Response.body)
            ? (item?.data).flatMap { "\tBody: "+(String(data: $0, encoding: .utf8) ?? "<parser error>") }
            : nil
        var exception: String?
        if case .failure(let error) = result {
            exception = "\tError: "+error.localizedDescription
        }
        // Compose.
        let components = [url, statusCode, header, body, exception].compactMap { $0 }
        guard !components.isEmpty else { return }
        let log = (["Response:"]+components).joined(separator: "\n")
        handler(log)
    }
}
