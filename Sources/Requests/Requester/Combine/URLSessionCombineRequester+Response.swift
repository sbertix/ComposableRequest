//
//  URLSessionCombineRequester+Output.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 19/08/21.
//

#if canImport(Combine)
import Combine
import Foundation

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public extension URLSessionCombineRequester {
    /// A `struct` defining the output for a `URLSessionCombineRequester`.
    struct Response<Success>: URLSessionCombineReceivable {
        /// The underlying publisher.
        public let publisher: AnyPublisher<Success, Error>

        /// The underlying response.
        public var response: URLSessionCombineRequester.Response<Success> {
            self
        }

        /// Init.
        ///
        /// - parameter publisher: Some `Publisher`.
        /// - note: This cannot be constructed directly.
        public init<P: Publisher>(publisher: P) where P.Output == Success {
            self.publisher = publisher.catch { Fail(error: $0 as Error) }.eraseToAnyPublisher()
        }
    }
}
#endif
