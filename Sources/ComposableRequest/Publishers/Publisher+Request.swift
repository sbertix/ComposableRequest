//
//  Projectable+Request.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 23/02/21.
//

import Foundation

public extension Request {
    /// Prepare a future.
    ///
    /// - parameter input: A valid `SessionProviderInput`.
    /// - returns: Some `Publisher`.
    func publish(with input: SessionProviderInput) -> AnyPublisher<Request.Response, Swift.Error> {
        // Proceed for valid requests only.
        guard let request = self.request() else {
            return Fail(error: Error.invalidRequest(self)).eraseToAnyPublisher()
        }
        // Return the actual stream.
        let logger = input.logger ?? Logger.default
        return input.session
            .dataTaskPublisher(for: request)
            .retry(max(input.retries, 0))
            .map(Request.Response.init)
            .catch { Fail<Request.Response, Swift.Error>(error: $0) }
            .handleEvents(
                receiveSubscription: { _ in logger.log(request) },
                receiveOutput: { logger.log(.success($0)) },
                receiveCompletion: { if case .failure(let error) = $0 { logger.log(.failure(error)) } }
            )
            .eraseToAnyPublisher()
    }

    /// Prepare a future.
    ///
    /// - parameters:
    ///     - session: A valid `URLSession`.
    ///     - retries: A valid `Int`. Defaults to `0`.
    ///     - logger: An optional `Logger`. Defaults to `nil`, meaning `Logger.default` will be used instead.
    /// - returns: Some `Projectable`.
    func publish(session: URLSession,
                 retries: Int = 0,
                 logging logger: Logger? = nil) -> AnyPublisher<Request.Response, Swift.Error> {
        self.publish(with: .init(session: session,
                                 retries: retries,
                                 logger: logger))
    }
}
