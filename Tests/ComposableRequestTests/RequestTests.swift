//
//  RequestTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 18/08/21.
//

#if canImport(Combine)
import Combine
import Foundation
import XCTest

@testable import Requests

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
internal final class RequestTests: XCTestCase {
    private var bin: Set<AnyCancellable>!

    override func setUp() {
        bin = []
    }

    #if swift(>=5.5)
    // swiftlint:disable empty_xctest_method
    @available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
    /// Test structured concurrency.
    func testAsyncRequest() async throws {
        let response = try await Request.endpoint()
        .prepare(with: .async(session: .shared))
        XCTAssertEqual(response, 2)
    }

    @available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
    /// Test structured concurrency.
    func testAsyncConditionalRequest() async throws {
        let trueResponse = try await Request.endpoint(true)
            .prepare(with: .async(session: .shared))
        XCTAssertEqual(trueResponse, 1)
        let falseResponse = try await Request.endpoint(false)
            .prepare(with: .async(session: .shared))
        XCTAssertEqual(falseResponse, 0)
    }

    @available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
    /// Test paginated structured concurrency.
    ///
    /// - note: `URLSessionAsyncRequester` can only paginate once.
    func testAsyncPaginatedRequest() async throws {
        let response = try await Request.endpoint()
            .offset(0)
            .prepare(with: .async(session: .shared))
        XCTAssertEqual(response, 0)
    }

    @available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
    /// Test requested structured concurrency.
    func testAsyncRequestedRequest() async throws {
        let response = try await Request.requestedEndpoint()
            .prepare(with: .async(session: .shared))
        XCTAssertEqual(response, 2)
    }
    // swiftlint:enable empty_xctest_method
    #endif

    /// Test combine.
    func testCombineRequest() {
        let expectation = XCTestExpectation()
        Request.endpoint()
            .prepare(with: URLSessionCombineRequester(session: .shared))
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
                expectation.fulfill()
            }, receiveValue: {
                XCTAssertEqual($0, 2)
            })
            .store(in: &bin)
        wait(for: [expectation], timeout: 5)
    }

    /// Test combine.
    func testCombineConditionalRequest() {
        let expectations = [XCTestExpectation(description: "true"),
                            XCTestExpectation(description: "false")]
        Request.endpoint(true)
            .prepare(with: URLSessionCombineRequester(session: .shared))
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
            }, receiveValue: {
                XCTAssertEqual($0, 1)
                expectations.first?.fulfill()
            })
            .store(in: &bin)
        Request.endpoint(false)
            .prepare(with: URLSessionCombineRequester(session: .shared))
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
            }, receiveValue: {
                XCTAssertEqual($0, 0)
                expectations.last?.fulfill()
            })
            .store(in: &bin)
        wait(for: expectations, timeout: 10)
    }

    /// Test combine.
    func testCombinePaginatedRequest() {
        let count = 5
        let expectations = (0...5).map { _ in XCTestExpectation() }
        Request.endpoint()
            .offset(0, pages: count)
            .prepare(with: URLSessionCombineRequester(session: .shared))
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
                expectations.last?.fulfill()
            }, receiveValue: {
                expectations[$0].fulfill()
            })
            .store(in: &bin)
        wait(for: expectations, timeout: 5 * TimeInterval(count))
    }

    /// Test combine.
    func testCombineRequestedRequest() {
        let expectation = XCTestExpectation()
        Request.requestedEndpoint()
            .prepare(with: URLSessionCombineRequester(session: .shared))
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
                expectation.fulfill()
            }, receiveValue: {
                XCTAssertEqual($0, 2)
            })
            .store(in: &bin)
        wait(for: [expectation], timeout: 5)
    }

    /// Test completion.
    func testCompletionRequest() {
        let expectation = XCTestExpectation()
        Request.endpoint()
            .prepare(with: URLSessionCompletionRequester(session: .shared))
            .onSuccess({
                XCTAssertEqual($0, 2); expectation.fulfill()
            }, onFailure: {
                XCTFail($0.localizedDescription)
            })
            .resume()
        wait(for: [expectation], timeout: 5)
    }

    /// Test conditional completion.
    func testConditionalCompletionRequest() {
        let expectations = [XCTestExpectation(description: "true"),
                            XCTestExpectation(description: "false")]
        Request.endpoint(true)
            .prepare(with: URLSessionCompletionRequester(session: .shared))
            .onSuccess({
                XCTAssertEqual($0, 1); expectations.first?.fulfill()
            }, onFailure: {
                XCTFail($0.localizedDescription)
            })
            .resume()
        Request.endpoint(false)
            .prepare(with: URLSessionCompletionRequester(session: .shared))
            .onSuccess({
                XCTAssertEqual($0, 0); expectations.last?.fulfill()
            }, onFailure: {
                XCTFail($0.localizedDescription)
            })
            .resume()
        wait(for: expectations, timeout: 10)
    }

    /// Test paginated completion.
    ///
    /// - note: `URLSessionCompletionRequester` can only paginate once.
    func testPaginatedCompletionRequest() {
        let expectation = XCTestExpectation()
        Request.endpoint()
            .offset(0)
            .prepare(with: URLSessionCompletionRequester(session: .shared))
            .onSuccess({
                XCTAssertEqual($0, 0); expectation.fulfill()
            }, onFailure: {
                XCTFail($0.localizedDescription)
            })
            .resume()
        wait(for: [expectation], timeout: 5)
    }

    /// Test requested completion.
    func testRequestedCompletionRequest() {
        let expectation = XCTestExpectation()
        Request.requestedEndpoint()
            .prepare(with: URLSessionCompletionRequester(session: .shared))
            .onSuccess({
                XCTAssertEqual($0, 2); expectation.fulfill()
            }, onFailure: {
                XCTFail($0.localizedDescription)
            })
            .resume()
        wait(for: [expectation], timeout: 5)
    }
}

fileprivate extension Request {
    /// The paginated endpoint.
    typealias PaginatedEndpoint<R: Requester> = R.Output
        .Map<Int>
        .Map<Int>
        .Pager<Int>

    /// The conditional endpoint.
    typealias ConditionalEndpoint<R: Requester> = Receivables.If<
        R.Output.Map<Int>,
        R.Output.Map<Int>
    >

    /// Prepare a random endpoint.
    ///
    /// - returns: Some `Receivable`.
    @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
    static func endpoint<R: Requester>() -> Providers.Requester<R, R.Requested<Int>> {
        .init { requester in
            Request("https://gist.githubusercontent.com/sbertix/8959f2534f815ee3f6018965c6c5f9e2/raw/ce697fafd1b34ad90cccd9a919a9b0b48574e1ac/Test.json")
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map { $0["string"].string(converting: true) ?? "" }
                .encode(encoder: JSONEncoder())
                .decode(type: String.self, decoder: JSONDecoder())
                .map { $0 == "A random string." }
                .switch { _ in
                    Request("https://google.com")
                        .prepare(with: requester)
                        .map { _ in 1 }
                }
                .switch {
                    Receivables.Once(output: $0 + 1, with: requester)
                }
                .requested(by: requester)
        }
    }

    /// Prepare a random paginated endpoint.
    ///
    /// - returns: Some `Receivable`.
    static func endpoint<R: Requester>() -> Providers.PageRequester<Int, R, PaginatedEndpoint<R>> {
        .init { page, requester in
            .init(page,
                  generator: { offset in
                    Request("https://google.com?q=\(offset)")
                        .prepare(with: requester)
                        .map(\.data.count)
                        .map { _ in offset }
                  },
                  nextOffset: {
                    .offset($0 + 1)
                  })
        }
    }

    /// Prepare a random conditional endpoint.
    ///
    /// - parameter condition: A valid `Bool`.
    /// - returns: Some `Receivable`.
    static func endpoint<R: Requester>(_ condition: Bool) -> Providers.Requester<R, ConditionalEndpoint<R>> {
        .init { requester in
            .init(condition,
                  onTrue: {
                    Request("https://google.com")
                        .prepare(with: requester)
                        .map { _ in 1 }
                  },
                  onFalse: {
                    Request("https://google.com")
                        .prepare(with: requester)
                        .map { _ in 0 }
                  })
        }
    }

    /// Prepare a type-erased endpoint.
    ///
    /// - returns: Some `Receivable`.
    @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
    static func requestedEndpoint<R: Requester>() -> Providers.Requester<R, R.Requested<Int>> {
        .init {
            endpoint()
                .prepare(with: $0)
                .requested(by: $0)
        }
    }
}
#endif
