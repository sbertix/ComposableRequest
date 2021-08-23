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
    /// The underlying response.
    var response: URLSessionCombineRequester.Response<Success> { get }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public extension URLSessionCombineReceivable {
    /// The underlying publisher.
    var publisher: AnyPublisher<Success, Error> {
        response.publisher
    }
}

// MARK: Provider

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public extension RequesterProvider where Output: URLSessionCombineReceivable {
    /// Update the requester.
    ///
    /// - parameter input: A valid `Input`.
    /// - returns: Some `Output.Success` publisher.
    func prepare(with requester: Input) -> AnyPublisher<Output.Success, Error> {
        prepare(with: requester).publisher
    }
}

// MARK: Receivables

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.FlatMap: URLSessionCombineReceivable where Parent: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.tryMap { try self.mapper($0).get() })
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.FlatMapError: URLSessionCombineReceivable where Parent: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.catch { error in Future { $0(self.mapper(error)) } })
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.If: URLSessionCombineReceivable
where O1: URLSessionCombineReceivable, O2: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: condition ? trueGenerator().publisher : falseGenerator().publisher)
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Map: URLSessionCombineReceivable where Parent: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.map(mapper))
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.MapError: URLSessionCombineReceivable where Parent: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.catch { Fail(error: self.mapper($0)) })
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Pager: URLSessionCombineReceivable where Child: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: generator(offset)
                .publisher
                .flatMap { success in
                    Just(success)
                        .setFailureType(to: Error.self)
                        .append(Just(self.nextOffset(success))
                                    .setFailureType(to: Error.self)
                                    .compactMap {
                                        if case .offset(let offset) = $0 { return offset } else { return nil }
                                    }
                                    .flatMap {
                                        Receivables.Pager(offset: $0,
                                                          count: self.count - 1,
                                                          generator: self.generator,
                                                          nextOffset: self.nextOffset)
                                            .publisher
                                    })
                }
                .prefix(count))
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Print: URLSessionCombineReceivable where Parent: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.print())
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Switch: URLSessionCombineReceivable
where Parent: URLSessionCombineReceivable, Child: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.flatMap { self.generator($0).publisher })
    }
}
#endif
