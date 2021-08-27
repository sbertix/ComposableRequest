//
//  URLSessionCombineReceivable.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 20/08/21.
//

#if canImport(Combine)
import Combine
import Foundation

/// A `protocol` defining a mock `URLSessionCombineReceivable`.
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public protocol URLSessionCombineMockReceivable {
    // swiftlint:disable identifier_name
    /// The underlying mock response.
    var _mockResponse: Any { get }
    // swiftlint:enable identifier_name
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
/// A `protocol` defining a generic combine receivable.
public protocol URLSessionCombineReceivable: Receivable, URLSessionCombineMockReceivable {
    /// The underlying response.
    var response: URLSessionCombineRequester.Response<Success> { get }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public extension URLSessionCombineReceivable {
    // swiftlint:disable identifier_name
    /// The underlying mock response.
    var _mockResponse: Any {
        response
    }
    // swiftlint:enable identifier_name

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
extension Receivables.FlatMap: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where Parent: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.tryMap { try self.mapper($0).get() })
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.FlatMapError: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where Parent: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.catch { error in Future { $0(self.mapper(error)) } })
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Future: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where Requester: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: Future { resolve in self.completion { resolve($0) } })
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.If: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where O1: URLSessionCombineReceivable, O2: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: condition ? trueGenerator().publisher : falseGenerator().publisher)
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Map: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where Parent: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.map(mapper))
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.MapError: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where Parent: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.catch { Fail(error: self.mapper($0)) })
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Once: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where Requester.Output: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        switch result {
        case .success(let output):
            return .init(publisher: Just(output).setFailureType(to: Error.self))
        case .failure(let error):
            return .init(publisher: Fail(error: error))
        }
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Pager: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where Child: URLSessionCombineReceivable {
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
extension Receivables.Print: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where Parent: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.print())
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Requested: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where Requester.Output: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        // swiftlint:disable force_cast
        (reference as! URLSessionCombineMockReceivable)._mockResponse as! URLSessionCombineRequester.Response<Success>
        // swiftlint:enable force_cast
    }
}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Receivables.Switch: URLSessionCombineReceivable, URLSessionCombineMockReceivable
where Parent: URLSessionCombineReceivable, Child: URLSessionCombineReceivable {
    /// The underlying response.
    public var response: URLSessionCombineRequester.Response<Success> {
        .init(publisher: parent.publisher.flatMap { publisher -> AnyPublisher<Success, Error> in
            do {
                return try self.generator(publisher).publisher.eraseToAnyPublisher()
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        })
    }
}
#endif
