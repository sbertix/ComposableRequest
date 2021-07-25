//
//  URLSessionCompletionReceivable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

import Foundation

/// A `protocol` defining a generic completion receivable.
public protocol URLSessionCompletionReceivable: Receivable {
    /// The delegate.
    var handler: URLSessionCompletionRequester.Response<Success>.Handler { get }

    @discardableResult
    /// Resume.
    ///
    /// - returns: An optional `URLSessionDataTask`.
    func resume() -> URLSessionDataTask?
}

public extension URLSessionCompletionReceivable {
    /// Update the completion handler.
    ///
    /// - parameter handler: A valid handler.
    /// - returns: `self`.
    func onResult(_ handler: @escaping (Result<Success, Error>) -> Void) -> Self {
        self.handler.completion = handler
        return self
    }

    /// Update the completion handler.
    ///
    /// - parameters:
    ///     - success: A valid success handler.
    ///     - failrue: An optional failure handler.  Defaults to `nil`.
    /// - returns: `self`.
    func onSuccess(_ success: @escaping (Success) -> Void, onFailure failure: ((Error) -> Void)? = nil) -> Self {
        handler.completion = {
            switch $0 {
            case .success(let output):
                success(output)
            case .failure(let error):
                failure?(error)
            }
        }
        return self
    }
}

// MARK: Receivables

extension Receivables.FlatMap: URLSessionCompletionReceivable where Parent: URLSessionCompletionReceivable {
    /// The delegate.
    public var handler: URLSessionCompletionRequester.Response<Success>.Handler {
        let delegate = URLSessionCompletionRequester.Response<Success>.Handler()
        parent.handler.completion = {
            switch $0 {
            case .success(let success):
                delegate.completion?(mapper(success))
            case .failure(let failure):
                delegate.completion?(.failure(failure))
            }
        }
        return delegate
    }

    @discardableResult
    /// Resume.
    ///
    /// - returns: An optional `URLSessionDataTask`.
    public func resume() -> URLSessionDataTask? {
        parent.resume()
    }
}

extension Receivables.FlatMapError: URLSessionCompletionReceivable where Parent: URLSessionCompletionReceivable {
    /// The delegate.
    public var handler: URLSessionCompletionRequester.Response<Success>.Handler {
        let delegate = URLSessionCompletionRequester.Response<Success>.Handler()
        parent.handler.completion = {
            switch $0 {
            case .success(let success):
                delegate.completion?(.success(success))
            case .failure(let failure):
                delegate.completion?(mapper(failure))
            }
        }
        return delegate
    }

    @discardableResult
    /// Resume.
    ///
    /// - returns: An optional `URLSessionDataTask`.
    public func resume() -> URLSessionDataTask? {
        parent.resume()
    }
}

extension Receivables.Map: URLSessionCompletionReceivable where Parent: URLSessionCompletionReceivable {
    /// The delegate.
    public var handler: URLSessionCompletionRequester.Response<Success>.Handler {
        let delegate = URLSessionCompletionRequester.Response<Success>.Handler()
        parent.handler.completion = {
            switch $0 {
            case .success(let success):
                delegate.completion?(.success(mapper(success)))
            case .failure(let failure):
                delegate.completion?(.failure(failure))
            }
        }
        return delegate
    }

    @discardableResult
    /// Resume.
    ///
    /// - returns: An optional `URLSessionDataTask`.
    public func resume() -> URLSessionDataTask? {
        parent.resume()
    }
}

extension Receivables.MapError: URLSessionCompletionReceivable where Parent: URLSessionCompletionReceivable {
    /// The delegate.
    public var handler: URLSessionCompletionRequester.Response<Success>.Handler {
        let delegate = URLSessionCompletionRequester.Response<Success>.Handler()
        parent.handler.completion = {
            switch $0 {
            case .success(let success):
                delegate.completion?(.success(success))
            case .failure(let failure):
                delegate.completion?(.failure(mapper(failure)))
            }
        }
        return delegate
    }

    @discardableResult
    /// Resume.
    ///
    /// - returns: An optional `URLSessionDataTask`.
    public func resume() -> URLSessionDataTask? {
        parent.resume()
    }
}

extension Receivables.Print: URLSessionCompletionReceivable where Parent: URLSessionCompletionReceivable {
    /// The delegate.
    public var handler: URLSessionCompletionRequester.Response<Success>.Handler {
        let delegate = URLSessionCompletionRequester.Response<Success>.Handler()
        parent.handler.completion = {
            Swift.print($0)
            delegate.completion?($0)
        }
        return delegate
    }

    @discardableResult
    /// Resume.
    ///
    /// - returns: An optional `URLSessionDataTask`.
    public func resume() -> URLSessionDataTask? {
        parent.resume()
    }
}

extension Receivables.Switch: URLSessionCompletionReceivable
where Parent: URLSessionCompletionReceivable, Child: URLSessionCompletionReceivable {
    /// The delegate.
    public var handler: URLSessionCompletionRequester.Response<Success>.Handler {
        let delegate = URLSessionCompletionRequester.Response<Success>.Handler()
        parent.handler.completion = {
            switch $0 {
            case .success(let success):
                generator(success).onResult { delegate.completion?($0) }.resume()
            case .failure(let failure):
                delegate.completion?(.failure(failure))
            }
        }
        return delegate
    }

    @discardableResult
    /// Resume.
    ///
    /// - returns: An optional `URLSessionDataTask`.
    public func resume() -> URLSessionDataTask? {
        parent.resume()
    }
}
