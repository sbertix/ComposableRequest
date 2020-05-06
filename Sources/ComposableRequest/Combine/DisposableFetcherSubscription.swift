//
//  DisposableFetcherSubscription.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 05/05/2020.
//

#if canImport(Combine)
import Combine
import Foundation

/// A `class` defining a new `Subscription` specific for `Response`s coming from `DisposableRequestable` requests.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class DisposableFetcherSubscription<Fetcher: DisposableRequestable, Subscriber: Combine.Subscriber>: Subscription
where Subscriber.Input == Fetcher.Response, Subscriber.Failure == Error {
    /// A `Subscriber`.
    private var subscriber: Subscriber?
    /// A `Requester.Task`.
    private var task: Requester.Task? {
        didSet {
            guard task?.identifier != oldValue?.identifier else { return }
        }
    }

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
        self.task = fetcher.task(by: requester) {
            switch $0 {
            case .failure(let error): subscriber.receive(completion: .failure(error))
            case .success(let value):
                _ = subscriber.receive(value)
                subscriber.receive(completion: .finished)
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
        self.task?.resume()
    }

    /// Cancel.
    public func cancel() {
        self.task = nil
        self.subscriber = nil
    }
}
#endif
