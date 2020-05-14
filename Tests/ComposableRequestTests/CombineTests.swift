//
//  ComposableTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

@testable import ComposableRequest
import XCTest

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class CombineTests: XCTestCase {
    /// The actual request.
    let request = Request("https://www.instagram.com")
    /// The current cancellable.
    var requestCancellable: AnyCancellable?

    /// Test `Request`.
    func testRequest() {
        let expectation = XCTestExpectation()
        requestCancellable = request
            .prepare { $0.map { String(data: $0, encoding: .utf8) ?? "" }}
            .publish()
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let error): XCTFail(error.localizedDescription)
                default: break
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
        wait(for: [expectation], timeout: 10)
    }

    /// Test `Pagination`.
    func testPagination() {
        var count = 0
        let expectation = XCTestExpectation()
        requestCancellable = request
            .prepare(processor: { $0.map { String(data: $0, encoding: .utf8) ?? "" }},
                     pager: { request, _ in request.appending(query: "l", with: "en") })
            .publish()
            .prefix(10)
            .sink(receiveCompletion: { _ in expectation.fulfill() },
                  receiveValue: { _ in
                    count += 1
            })
        wait(for: [expectation], timeout: 30)
        XCTAssert(count == 10)
    }

    /// Test empty `Pagination`.
    func testEmptyPagination() {
        var count = 0
        let expectation = XCTestExpectation()
        requestCancellable = request
            .prepare { request, _ in request.appending(query: "l", with: "en") }
            .publish()
            .prefix(0)
            .sink(receiveCompletion: { _ in expectation.fulfill() },
                  receiveValue: { _ in
                    count += 1
            })
        wait(for: [expectation], timeout: 10)
        XCTAssert(count == 0)
    }

    /// Test `Request` cancelling.
    func testCancel() {
        let expectation = XCTestExpectation()
        request
            .prepare()
            .publish()
            .handleEvents(receiveCancel: { expectation.fulfill() })
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .cancel()
        wait(for: [expectation], timeout: 5)
    }

    static var allTests = [
        ("Request", testRequest),
        ("Request.Pagination", testPagination),
        ("Request.Empty.Pagination", testEmptyPagination),
        ("Request.Cancel", testCancel)
    ]
}
#endif
