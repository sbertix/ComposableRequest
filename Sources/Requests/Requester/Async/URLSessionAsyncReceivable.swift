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
    /// The underlying response.
    var response: URLSessionAsyncRequester.Response<Success> { get }
}

// swiftlint:disable implicit_getter
@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public extension URLSessionAsyncReceivable {
    /// Access the underlying value.
    var value: Success {
        get async throws { try await response.task.value }
    }

    /// Access the underlying result.
    var result: Result<Success, Error> {
        get async { await response.task.result }
    }

    /// Cancel.
    func cancel() {
        response.task.cancel()
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
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain(mapper)
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.FlatMapError: URLSessionAsyncReceivable where Parent: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain(mapper)
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.If: URLSessionAsyncReceivable where O1: URLSessionAsyncReceivable, O2: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        condition ? trueGenerator().response : falseGenerator().response
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Map: URLSessionAsyncReceivable where Parent: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain { .success(self.mapper($0)) }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.MapError: URLSessionAsyncReceivable where Parent: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain { .failure(self.mapper($0)) }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Pager: URLSessionAsyncReceivable where Child: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        precondition(count == 1, "`URLSessionAsyncReceivable` can only produce one result")
        return generator(offset).response
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Print: URLSessionAsyncReceivable where Parent: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain { (result: Result<Success, Error>) in Swift.print(result); return result }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Switch: URLSessionAsyncReceivable
where Parent: URLSessionAsyncReceivable, Child: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain { await generator($0).result }
    }
}
// swiftlint:enable implicit_getter
#endif
