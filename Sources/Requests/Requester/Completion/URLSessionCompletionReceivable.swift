//
//  URLSessionCompletionReceivable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

/// A `protocol` defining a generic completion receivable.
public protocol URLSessionCompletionReceivable: Receivable {
    /// The response.
    var response: URLSessionCompletionRequester.Response<Success> { get }
}

public extension URLSessionCompletionReceivable {
    /// Update the completion handler.
    ///
    /// - parameter handler: A valid handler.
    /// - returns: `self`.
    func onResult(_ handler: @escaping (Result<Success, Error>) -> Void) -> URLSessionCompletionRequester.Response<Success> {
        let response = self.response
        response.handler.completion = handler
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

extension Receivables.FlatMap: URLSessionCompletionReceivable where Parent: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        parent.response.chain(mapper)
    }
}

extension Receivables.FlatMapError: URLSessionCompletionReceivable where Parent: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        parent.response.chain(mapper)
    }
}

extension Receivables.If: URLSessionCompletionReceivable
where O1: URLSessionCompletionReceivable, O2: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        condition ? trueGenerator().response : falseGenerator().response
    }
}

extension Receivables.Map: URLSessionCompletionReceivable where Parent: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        parent.response.chain { .success(self.mapper($0)) }
    }
}

extension Receivables.MapError: URLSessionCompletionReceivable where Parent: URLSessionCompletionReceivable {
    /// The response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        parent.response.chain { .failure(self.mapper($0)) }
    }
}

extension Receivables.Pager: URLSessionCompletionReceivable where Child: URLSessionCompletionReceivable {
    /// The underlying response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        precondition(count == 1, "`URLSessionCompletionReceivable` can only produce one result")
        return generator(offset).response
    }
}

extension Receivables.Print: URLSessionCompletionReceivable where Parent: URLSessionCompletionReceivable {
    /// The underlyhing response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        parent.response.chain { (result: Result<Success, Error>) in Swift.print(result); return result }
    }
}

extension Receivables.Switch: URLSessionCompletionReceivable
where Parent: URLSessionCompletionReceivable, Child: URLSessionCompletionReceivable {
    /// The undelrying response.
    public var response: URLSessionCompletionRequester.Response<Success> {
        let handler = URLSessionCompletionRequester.Response<Success>.Handler()
        let response = parent.response
        response.handler.completion = {
            switch $0 {
            case .success(let success):
                self.generator(success).onResult { handler.completion?($0) }.resume()
            case .failure(let failure):
                handler.completion?(.failure(failure))
            }
        }
        return .init(value: response.value, handler: handler)
    }
}
