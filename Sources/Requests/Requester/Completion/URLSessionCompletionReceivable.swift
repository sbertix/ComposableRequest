//
//  URLSessionCompletionReceivable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

import Future

/// A `protocol` defining a mock `URLSessionCompletionReceivable`.
public protocol URLSessionCompletionMockReceivable {
    // swiftlint:disable identifier_name
    /// The underlying mock response.
    var _mockResponse: Any { get }
    // swiftlint:enable identifier_name
}

/// A `protocol` defining a generic completion receivable.
public protocol URLSessionCompletionReceivable: Receivable, URLSessionCompletionMockReceivable {
    /// The response.
    var response: URLSessionCompletionRequester.Response<Success> { get }
}

public extension URLSessionCompletionReceivable {
    // swiftlint:disable identifier_name
    /// The underlying mock response.
    var _mockResponse: Any {
        response
    }
    // swiftlint:enable identifier_name

    /// Update the completion handler.
    ///
    /// - parameter handler: A valid handler.
    /// - returns: `self`.
    func onResult(_ handler: @escaping (Result<Success, Error>) -> Void) -> URLSessionCompletionRequester.Response<Success> {
        let response = self.response
        response.future.on(success: { handler(.success($0)) },
                           failure: { handler(.failure($0)) },
                           completion: nil)
        return response
    }

    /// Update the completion handler.
    ///
    /// - parameters:
    ///     - success: A valid success handler.
    ///     - failrue: An optional failure handler.  Defaults to `nil`.
    /// - returns: `self`.
    func onSuccess(_ success: @escaping (Success) -> Void, onFailure failure: ((Error) -> Void)? = nil) -> URLSessionCompletionRequester.Response<Success> {
        onResult {
            switch $0 {
            case .success(let output):
                success(output)
            case .failure(let error):
                failure?(error)
            }
        }
    }
}

// MARK: Receivables

extension Receivables.FlatMap: URLSessionCompletionReceivable, URLSessionCompletionMockReceivable
where Parent: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        parent.response.chain(mapper)
    }
}

extension Receivables.FlatMapError: URLSessionCompletionReceivable, URLSessionCompletionMockReceivable
where Parent: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        parent.response.chain(mapper)
    }
}

extension Receivables.If: URLSessionCompletionReceivable, URLSessionCompletionMockReceivable
where O1: URLSessionCompletionReceivable, O2: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        condition ? trueGenerator().response : falseGenerator().response
    }
}

extension Receivables.Map: URLSessionCompletionReceivable, URLSessionCompletionMockReceivable
where Parent: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        parent.response.chain { .success(self.mapper($0)) }
    }
}

extension Receivables.MapError: URLSessionCompletionReceivable, URLSessionCompletionMockReceivable
where Parent: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        parent.response.chain { .failure(self.mapper($0)) }
    }
}

extension Receivables.Once: URLSessionCompletionReceivable, URLSessionCompletionMockReceivable
where Requester.Output: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        .init(task: nil, future: .init(result: result))
    }
}

extension Receivables.Pager: URLSessionCompletionReceivable, URLSessionCompletionMockReceivable
where Child: URLSessionCompletionReceivable {
    /// The underlying response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        precondition(count == 1, "`URLSessionCompletionReceivable` can only produce one result")
        return generator(offset).response
    }
}

extension Receivables.Print: URLSessionCompletionReceivable, URLSessionCompletionMockReceivable
where Parent: URLSessionCompletionReceivable {
    /// The underlyhing response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        parent.response.chain { (result: Result<Success, Error>) in Swift.print(result); return result }
    }
}

extension Receivables.Requested: URLSessionCompletionReceivable, URLSessionCompletionMockReceivable
where Requester.Output: URLSessionCompletionReceivable {
    /// The underlyhing response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        // swiftlint:disable force_cast
        (reference as! URLSessionCompletionMockReceivable)
            ._mockResponse as! URLSessionCompletionRequester.Response<Success>
        // swiftlint:enable force_cast
    }
}

extension Receivables.Switch: URLSessionCompletionReceivable, URLSessionCompletionMockReceivable
where Parent: URLSessionCompletionReceivable, Child: URLSessionCompletionReceivable {
    /// The undelrying response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        let promise = Promise<Success, Error>()
        let response = parent.response
        response.future.on(
            success: {
                do {
                    try self.generator($0).onResult { promise.resolve(result: $0) }.resume()
                } catch {
                    promise.fail(error: error)
                }
            },
            failure: {
                promise.fail(error: $0)
            }
        )
        return .init(task: response.task, future: promise.future)
    }
}
