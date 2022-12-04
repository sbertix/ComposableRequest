//
//  URLSession.swift
//  Requests
//
//  Created by Stefano Bertagno on 05/12/22.
//

import Foundation

public extension URLSession {
    /// Resolve a version-agnostic `URLSession` data task.
    ///
    /// - parameter request: A valid `URLRequest`
    /// - throws: Any `Error`.
    /// - returns: Some `Data` and `URLResponse` tuple.
    @_spi(Private)
    func _data(for request: URLRequest) async throws -> (data: Data, response: URLResponse) {
        if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
            return try await data(for: request)
        } else {
            var task: URLSessionDataTask?
            let onCancel = { task?.cancel() }
            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    task = self.dataTask(with: request) { data, response, error in
                        if let error = error { return continuation.resume(throwing: error) }
                        // swiftlint:disable:next force_unwrapping
                        continuation.resume(returning: (data!, response!))
                    }
                    task?.resume()
                }
            } onCancel: {
                onCancel()
            }
        }
    }
}
