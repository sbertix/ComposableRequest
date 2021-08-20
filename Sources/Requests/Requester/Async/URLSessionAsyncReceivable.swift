//
//  URLSessionAsyncReceivable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

#if swift(>=5.5)
import Foundation

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
/// A `protocol` defining a generic async receivable.
public protocol URLSessionAsyncReceivable: Receivable {
    /// The underlying task.
    var task: Task<Success, Error> { get }
}

// swiftlint:disable implicit_getter
@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public extension URLSessionAsyncReceivable {
    /// Access the underlying value.
    var value: Success {
        get async throws { try await task.value }
    }

    /// Access the underlying result.
    var result: Result<Success, Error> {
        get async { await task.result }
    }

    /// Cancel.
    func cancel() {
        task.cancel()
    }
}

// MARK: Provider

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public extension RequesterProvider where Output: URLSessionAsyncReceivable {
    /// Update the requester.
    ///
    /// - parameter input: A valid `Input`.
    /// - returns: Some `Output.Success`.
    /// - throws: Some `Error`.
    func prepare(with requester: Input) async throws -> Output.Success {
        try await prepare(with: requester).value
    }
}

// MARK: Receivables

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.FlatMap: URLSessionAsyncReceivable where Parent: URLSessionAsyncReceivable {
    /// The underlying task.
    public var task: Task<Success, Error> {
        .init { try await mapper(parent.task.value).get() }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.FlatMapError: URLSessionAsyncReceivable where Parent: URLSessionAsyncReceivable {
    /// The underlying task.
    public var task: Task<Success, Error> {
        .init {
            switch await parent.task.result {
            case .success(let success): return success
            case .failure(let failure): return try mapper(failure).get()
            }
        }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Map: URLSessionAsyncReceivable where Parent: URLSessionAsyncReceivable {
    /// The underlying task.
    public var task: Task<Success, Error> {
        .init { try await mapper(parent.task.value) }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.MapError: URLSessionAsyncReceivable where Parent: URLSessionAsyncReceivable {
    /// The underlying task.
    public var task: Task<Success, Error> {
        .init {
            switch await parent.task.result {
            case .success(let success): return success
            case .failure(let failure): throw mapper(failure)
            }
        }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Print: URLSessionAsyncReceivable where Parent: URLSessionAsyncReceivable {
    /// The underlying task.
    public var task: Task<Success, Error> {
        .init {
            do {
                let success = try await parent.task.value
                Swift.print("success: \(success)")
                return success
            } catch {
                Swift.print("failure: \(error)")
                throw error
            }
        }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Switch: URLSessionAsyncReceivable
where Parent: URLSessionAsyncReceivable, Child: URLSessionAsyncReceivable {
    /// The underlying task.
    public var task: Task<Success, Error> {
        .init {
            switch await parent.task.result {
            case .success(let success): return try await generator(success).value
            case .failure(let failure): throw failure
            }
        }
    }
}
// swiftlint:enable implicit_getter
#endif
