//
//  URLSessionAsyncReceivable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

#if swift(>=5.5)
import Foundation

/// A `protocol` defining a mock `URLSessionAsyncReceivable`.
@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public protocol URLSessionAsyncMockReceivable {
    // swiftlint:disable identifier_name
    /// The underlying mock response.
    var _mockResponse: Any { get }
    // swiftlint:enable identifier_name
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
/// A `protocol` defining a generic async receivable.
public protocol URLSessionAsyncReceivable: Receivable, URLSessionAsyncMockReceivable {
    /// The underlying response.
    var response: URLSessionAsyncRequester.Response<Success> { get }
}

// swiftlint:disable implicit_getter
@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public extension URLSessionAsyncReceivable {
    // swiftlint:disable identifier_name
    /// The mock response.
    var _mockResponse: Any {
        response
    }
    // swiftlint:enable identifier_name

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
extension Receivables.FlatMap: URLSessionAsyncReceivable, URLSessionAsyncMockReceivable
where Parent: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain(mapper)
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.FlatMapError: URLSessionAsyncReceivable, URLSessionAsyncMockReceivable
where Parent: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain(mapper)
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.If: URLSessionAsyncReceivable, URLSessionAsyncMockReceivable
where O1: URLSessionAsyncReceivable, O2: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        condition ? trueGenerator().response : falseGenerator().response
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Map: URLSessionAsyncReceivable, URLSessionAsyncMockReceivable
where Parent: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain { .success(self.mapper($0)) }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.MapError: URLSessionAsyncReceivable, URLSessionAsyncMockReceivable
where Parent: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain { .failure(self.mapper($0)) }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Once: URLSessionAsyncReceivable, URLSessionAsyncMockReceivable
where Requester.Output: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        .init(priority: nil) { try self.result.get() }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Pager: URLSessionAsyncReceivable, URLSessionAsyncMockReceivable
where Child: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        precondition(count == 1, "`URLSessionAsyncReceivable` can only produce one result")
        return generator(offset).response
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Print: URLSessionAsyncReceivable, URLSessionAsyncMockReceivable
where Parent: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain { (result: Result<Success, Error>) in Swift.print(result); return result }
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Requested: URLSessionAsyncReceivable, URLSessionAsyncMockReceivable
where Requester.Output: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        // swiftlint:disable force_cast
        (reference as! URLSessionAsyncMockReceivable)._mockResponse as! URLSessionAsyncRequester.Response<Success>
        // swiftlint:enable force_cast
    }
}

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
extension Receivables.Switch: URLSessionAsyncReceivable, URLSessionAsyncMockReceivable
where Parent: URLSessionAsyncReceivable, Child: URLSessionAsyncReceivable {
    /// The underlying response.
    public var response: URLSessionAsyncRequester.Response<Success> {
        parent.response.chain { (result: Parent.Success) in
            do {
                return try await generator(result).result
            } catch {
                return .failure(error)
            }
        }
    }
}
// swiftlint:enable implicit_getter
#endif
