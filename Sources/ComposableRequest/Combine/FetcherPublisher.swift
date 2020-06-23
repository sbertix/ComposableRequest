//
//  FetcherPublisher.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 16/03/2020.
//

#if canImport(Combine)
import Combine
import Foundation

/// A `struct` defining a new `Publisher` specific for `Response`s coming from`PaginatableRequestable` requests.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct FetcherPublisher<Fetcher: PaginatedFetchable>: Publisher {
    /// Output a `Response` item.
    public typealias Output = Fetcher.Response
    /// Fail to any `Error`.
    public typealias Failure = Error

    /// A valid `Fetcher`.
    private var fetcher: Fetcher
    /// A valid `Requester`.
    private weak var requester: Requester?

    /// Init.
    /// - parameter
    ///     - fetcher: A valid `Fetcher`.
    ///     - requester: A strongly referenced `Requester`.
    public init(fetcher: Fetcher, requester: Requester) {
        self.fetcher = fetcher
        self.requester = requester
    }

    /// Receive the `Subscriber`.
    /// - parameter subscriber: A valid `Subscriber`.
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: FetcherSubscription(fetcher: fetcher,
                                                             requester: requester ?? .default,
                                                             subscriber: subscriber))
    }
}

/// A combine extension for `Request`.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension PaginatedFetchable {
    /// Return a `Response` publisher.
    /// - parameter requester: A valid `Requester`. Defaults to `.default`.
    /// - note: Call `.prefix(_)` or `.first()` to control the maximum amount of outputs to receive, otherwise it will exhaust them before completing.
    func publish(in requester: Requester = .default) -> FetcherPublisher<Self> {
        return .init(fetcher: self, requester: requester)
    }
}
#endif
