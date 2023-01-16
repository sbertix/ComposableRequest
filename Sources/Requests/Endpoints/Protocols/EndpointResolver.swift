//
//  EndpointSolver.swift
//  Requests
//
//  Created by Stefano Bertagno on 20/12/22.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// A `protocol` defining an instance capable of
/// resolving an endpoint chain.
public protocol EndpointResolver {
    /// Compose the `DefaultResponse`.
    ///
    /// - throws: Any `Error`.
    /// - returns: Some `DefaultResponse`.
    @_spi(Private)
    func resolve(_ request: URLRequest) async throws -> DefaultResponse

    #if canImport(Combine)
    /// Compose the `DefaultResponse`.
    ///
    /// - throws: Any `Error`.
    /// - returns: Some `DefaultResponse` publisher.
    @_spi(Private)
    func resolve(_ request: URLRequest) -> AnyPublisher<DefaultResponse, any Error>
    #endif
}

public extension EndpointResolver {
    #if canImport(Combine)
    /// Compose the `DefaultResponse`.
    ///
    /// - throws: Any `Error`.
    /// - returns: Some `DefaultResponse` publisher.
    @_spi(Private)
    func resolve(_ request: URLRequest) -> AnyPublisher<DefaultResponse, any Error> {
        // Hold reference to the task, so we can cancel
        // it according to the `Publisher` stream.
        var task: Task<Void, Never>?
        return Deferred {
            Combine.Future { subscriber in
                task = .init {
                    guard !Task.isCancelled else { return }
                    await subscriber(Result.async { try await resolve(request) })
                }
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
    #endif
}

public extension EndpointResolver where Self == URLSession {
    /// Return some `shared` `URLSession`.
    static var shared: Self {
        .shared
    }
}

extension URLSession: EndpointResolver {
    /// Compose the `DefaultResponse`.
    ///
    /// - throws: Any `Error`.
    /// - returns: Some `DefaultResponse`.
    @_spi(Private)
    public func resolve(_ request: URLRequest) async throws -> DefaultResponse {
        if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
            let (data, response) = try await data(for: request)
            return .init(response: response, data: data)
        } else {
            var task: URLSessionDataTask?
            let onCancel = { task?.cancel() }
            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    task = self.dataTask(with: request) { data, response, error in
                        if let error = error { return continuation.resume(throwing: error) }
                        // swiftlint:disable:next force_unwrapping
                        continuation.resume(returning: .init(response: response!, data: data!))
                    }
                    task?.resume()
                }
            } onCancel: {
                onCancel()
            }
        }
    }

    #if canImport(Combine)
    /// Compose the `DefaultResponse`.
    ///
    /// - throws: Any `Error`.
    /// - returns: Some `DefaultResponse` publisher.
    @_spi(Private)
    public func resolve(_ request: URLRequest) -> AnyPublisher<DefaultResponse, any Error> {
        dataTaskPublisher(for: request)
            .map { DefaultResponse(response: $0.response, data: $0.data) }
            .mapError { $0 as any Error }
            .eraseToAnyPublisher()
    }
    #endif
}
