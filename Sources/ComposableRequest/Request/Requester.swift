//
//  Requester.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `class` used to perform `Request`s.
public final class Requester {
    /// A shared instance of `Requester` configured with the default session.
    /// Set a custom one to have it used by default by all future requests.
    public static var `default` = Requester()

    /// A shared instance of `Requester` configured with an ephermeral session.
    public static let ephemeral = Requester(configuration: .init(sessionConfiguration: .ephemeral))

    /// A `Configuration`. Defaults to `.init()`.
    public private(set) var configuration: Configuration

    /// A set of `Requester.Task`s currently scheduled or undergoing fetching.
    private var tasks: Set<Requester.Task> = [] {
        didSet {
            let session = configuration.session()
            /// Fetch `Requester.Task` as they're added.
            tasks.subtracting(oldValue).forEach { $0.fetch(using: session, configuration: configuration) }
        }
    }

    // MARK: Lifecycle
    /// Deinit.
    deinit { tasks.forEach { $0.cancel() }}

    /// Init.
    /// - parameter configuration: A valid `Configuration`.
    public init(configuration: Configuration = .init()) { self.configuration = configuration }

    // MARK: Schedule
    /// Schedule a new `request`.
    /// - parameter request: A valid `Requester.Task`.
    internal func schedule(_ request: Requester.Task) {
        guard !tasks.insert(request).inserted else { return }
        request.fetch(using: configuration.session(), configuration: configuration)
    }

    /// Cancel a given `request`.
    /// - parameter request: A valid `Requester.Task`.
    internal func cancel(_ request: Requester.Task) { tasks.remove(request) }
}
