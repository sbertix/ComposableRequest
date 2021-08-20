//
//  URLSessionCombineReceivable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

#if canImport(Combine)
import Combine
import Foundation

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
/// A `protocol` defining a generic combine receivable.
public protocol URLSessionCombineReceivable: Receivable {
    /// The underlying publisher.
    var publisher: AnyPublisher<Success, Error> { get }
}

// MARK: Receivables

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.FlatMap: URLSessionCombineReceivable where Parent: URLSessionCombineReceivable {
    /// The underlying publisher.
    public var publisher: AnyPublisher<Success, Error> {
        parent.publisher.tryMap { try self.mapper($0).get() }.eraseToAnyPublisher()
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.FlatMapError: URLSessionCombineReceivable where Parent: URLSessionCombineReceivable {
    /// The underlying publisher.
    public var publisher: AnyPublisher<Success, Error> {
        parent.publisher.catch { error in Future { $0(self.mapper(error)) } }.eraseToAnyPublisher()
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Map: URLSessionCombineReceivable where Parent: URLSessionCombineReceivable {
    /// The underlying publisher.
    public var publisher: AnyPublisher<Success, Error> {
        parent.publisher.map(mapper).eraseToAnyPublisher()
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.MapError: URLSessionCombineReceivable where Parent: URLSessionCombineReceivable {
    /// The underlying publisher.
    public var publisher: AnyPublisher<Parent.Success, Error> {
        parent.publisher.catch { Fail(error: self.mapper($0)) }.eraseToAnyPublisher()
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Print: URLSessionCombineReceivable where Parent: URLSessionCombineReceivable {
    /// The underlying publisher.
    public var publisher: AnyPublisher<Parent.Success, Error> {
        parent.publisher.print().eraseToAnyPublisher()
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Switch: URLSessionCombineReceivable
where Parent: URLSessionCombineReceivable, Child: URLSessionCombineReceivable {
    /// The underlying publisher.
    public var publisher: AnyPublisher<Success, Error> {
        parent.publisher.flatMap { self.generator($0).publisher }.eraseToAnyPublisher()
    }
}
#endif
