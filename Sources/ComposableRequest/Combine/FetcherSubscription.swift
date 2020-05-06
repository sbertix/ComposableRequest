//
//  FetcherSubscription.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 11/03/2020.
//

#if canImport(Combine)
import Combine
import Foundation

/// A `class` defining a new `Subscription` specific for `Response`s coming from `PaginatableRequestable` requests.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class FetcherSubscription<Fetcher: PaginatedFetchable, Subscriber: Combine.Subscriber>: Subscription
where Subscriber.Input == Fetcher.Response, Subscriber.Failure == Error {
    /// A `Subscriber`.
    private var subscriber: Subscriber?
    /// A `Requester.Task`.
    private var task: Requester.Task? {
        didSet {
            guard task?.identifier != oldValue?.identifier else { return }
            self.count = 0
            self.max = .max
        }
    }
    /// The current fetched count.
    private var count: Int = 0
    /// The maximum amount to fetch.
    private var max: Int = .max

    // MARK: Lifecycle
    /// Deinit.
    deinit {
        task?.cancel()
    }

    /// Init.
    /// - parameters:
    ///     - fetcher: A valid `Fetcher`.
    ///     - requester: A valid `Requester`. Defaults to `.default`.
    ///     - subscriber: The `Subscriber`.
    internal init(fetcher: Fetcher,
                requester: Requester = .default,
                subscriber: Subscriber) {
        self.subscriber = subscriber
        self.task = fetcher.task(maxLength: .max,
                                 by: requester,
                                 onComplete: { [weak self] in
                                    guard let self = self, $0 < self.max else { return }
                                    subscriber.receive(completion: .finished)
        }) { [weak self] in
            guard let self = self else { return subscriber.receive(completion: .finished) }
            switch $0 {
            case .failure(let error): subscriber.receive(completion: .failure(error))
            case .success(let value):
                _ = subscriber.receive(value)
                // Check for `count` before completing.
                self.count += 1
                guard self.count < self.max else {
                    self.task?.cancel()
                    return subscriber.receive(completion: .finished)
                }
            }
        }
    }
    
    // MARK: Subscription
    /// Request. The default implementation does nothing.
    public func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else {
            subscriber?.receive(completion: .finished)
            return
        }
        self.max = demand.max ?? .max
        self.task?.resume()
    }

    /// Cancel.
    public func cancel() {
        self.task = nil
        self.subscriber = nil
    }
}
#endif
