//
//  APITests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 01/11/22.
//

import Combine
import Foundation
import XCTest

@_spi(Private)
@testable import Requests

/// A `class` defining tests for composition `protocol`s.
final class APItests: XCTestCase {
    /// The cancellable set used to test combine publishers.
    private var bin: Set<AnyCancellable> = []

    override func tearDown() {
        bin.removeAll()
    }

    // MARK: Builder

    func testBuilder() {
        // Prepare the components.
        @EndpointBuilder var components: TupleItem<Path, Components> {
            Method(.post)
            Path("https://google.com")
            Query("value", forKey: "key")
            Headers("value", forKey: "key")
            Body(.init())
            Service(.background)
            Cellular(false)
            Timeout(15)
            Constrained(false)
            Expensive(false)
        }
        // Test the request.
        // swiftlint:disable:next force_unwrapping
        let request = URLRequest(path: components.first.path, components: components.last.components)!
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.absoluteString, "https://google.com?key=value")
        XCTAssertEqual(request.allHTTPHeaderFields, ["key": "value"])
        XCTAssertEqual(request.httpBody, .init())
        XCTAssertEqual(request.networkServiceType, .background)
        XCTAssertEqual(request.allowsCellularAccess, false)
        XCTAssertEqual(request.timeoutInterval, 15)
        XCTAssertEqual(request.allowsConstrainedNetworkAccess, false)
        XCTAssertEqual(request.allowsExpensiveNetworkAccess, false)
    }

    // MARK: Single

    @EndpointBuilder private func singleEndpoint() -> AnySingleEndpoint<Int> {
        Path("https://gist.githubusercontent.com/sbertix/18271e0e549cac1f6a0d4276bf369c6e/raw/1da47924f034d21f87797edbe836abbe7c73dfd5/one.json")
        // swiftlint:disable:next force_unwrapping
        Response { try JSONDecoder().decode(AnyDecodable.self, from: $0).value.int! }
    }

    func testAsync() async throws {
        let reference = singleEndpoint()
        // Test single reference.
        let response = try await reference.resolve(with: .shared)
        XCTAssertEqual(response, 1)
        // Test targettable reference.
        var count: Int = 0
        for try await response in reference._resolve(with: .shared) {
            XCTAssertEqual(response, 1)
            count += 1
        }
        XCTAssertEqual(count, 1)
    }

    func testCombine() {
        let reference = singleEndpoint()
        // Test single reference.
        let expectation: XCTestExpectation = .init()
        expectation.assertForOverFulfill = true
        let responses: NSMutableSet = .init(set: [1])
        reference.resolve(with: .shared)
            .replaceError(with: 0)
            .sink { responses.remove($0); expectation.fulfill() }
            .store(in: &bin)
        wait(for: [expectation], timeout: 15)
        XCTAssertEqual(responses.count, 0)
        // Test targettable reference.
        let targettableExpectation: XCTestExpectation = .init()
        targettableExpectation.assertForOverFulfill = true
        responses.setSet([1])
        reference._resolve(with: .shared)
            .replaceError(with: 0)
            .sink { responses.remove($0); targettableExpectation.fulfill() }
            .store(in: &bin)
        wait(for: [targettableExpectation], timeout: 15)
        XCTAssertEqual(responses.count, 0)
    }

    // MARK: Loop

    @EndpointBuilder private func loopEndpoint() -> AnyLoopEndpoint<AnyDecodable> {
        Loop(startingAt: "https://gist.githubusercontent.com/sbertix/18271e0e549cac1f6a0d4276bf369c6e/raw/1da47924f034d21f87797edbe836abbe7c73dfd5/one.json") {
            Path($0)
            Response(AnyDecodable.self)
        } next: {
            $0.next.string
        }
    }

    func testAsyncStream() async throws {
        let reference = loopEndpoint()
        // Test stream reference.
        var count: Int = 0
        var responses: Set<Int> = [1, 2]
        for try await response in reference.resolve(with: .shared) {
            count += 1
            guard let value = response.value.int else { continue }
            responses.remove(value)
        }
        XCTAssertEqual(count, 2)
        XCTAssertTrue(responses.isEmpty)
        // Test targettable reference.
        count = 0
        responses = [1, 2]
        for try await response in reference._resolve(with: .shared) {
            count += 1
            guard let value = response.value.int else { continue }
            responses.remove(value)
        }
        XCTAssertEqual(count, 2)
        XCTAssertTrue(responses.isEmpty)
    }

    func testCombineStream() {
        let reference = loopEndpoint()
        // Test stream reference.
        let expectation: XCTestExpectation = .init()
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = 2
        let responses: NSMutableSet = .init(set: [1, 2])
        reference.resolve(with: .shared)
            .compactMap { $0.value.int }
            .replaceError(with: 0)
            .sink { responses.remove($0); expectation.fulfill() }
            .store(in: &bin)
        wait(for: [expectation], timeout: 15)
        XCTAssertEqual(responses.count, 0)
        // Test targettable reference.
        let targettableExpectation: XCTestExpectation = .init()
        targettableExpectation.assertForOverFulfill = true
        targettableExpectation.expectedFulfillmentCount = 2
        responses.setSet([1, 2])
        reference._resolve(with: .shared)
            .compactMap { $0.value.int }
            .replaceError(with: 0)
            .sink { responses.remove($0); targettableExpectation.fulfill() }
            .store(in: &bin)
        wait(for: [targettableExpectation], timeout: 15)
        XCTAssertEqual(responses.count, 0)
    }

    // MARK: Switch

    @EndpointBuilder private func switchSingleEndpoint() -> AnySingleEndpoint<Int> {
        Switch {
            Path("https://gist.githubusercontent.com/sbertix/18271e0e549cac1f6a0d4276bf369c6e/raw/1da47924f034d21f87797edbe836abbe7c73dfd5/one.json")
            // swiftlint:disable:next force_unwrapping
            Response { try JSONDecoder().decode(AnyDecodable.self, from: $0).next.string! }
        } to: {
            Path($0)
            // swiftlint:disable:next force_unwrapping
            Response { try JSONDecoder().decode(AnyDecodable.self, from: $0).value.int! }
        }
    }

    func testAsyncSwitch() async throws {
        let reference = switchSingleEndpoint()
        // Test single reference.
        let singleResponse = try await reference.resolve(with: .shared)
        XCTAssertEqual(singleResponse, 2)
        // Test targettable reference.
        var count: Int = 0
        for try await response in reference._resolve(with: .shared) {
            XCTAssertEqual(response, 2)
            count += 1
        }
        XCTAssertEqual(count, 1)
    }

    func testCombineSwitch() {
        let reference = switchSingleEndpoint()
        // Test single (and targettable) reference.
        let expectation: XCTestExpectation = .init()
        expectation.assertForOverFulfill = true
        let responses: NSMutableSet = .init(set: [2])
        reference.resolve(with: .shared)
            .replaceError(with: 0)
            .sink { responses.remove($0); expectation.fulfill() }
            .store(in: &bin)
        wait(for: [expectation], timeout: 15)
        XCTAssertEqual(responses.count, 0)
    }

    @EndpointBuilder private func switchLoopEndpoint() -> AnyLoopEndpoint<AnyDecodable> {
        Switch {
            Path("https://gist.githubusercontent.com/sbertix/18271e0e549cac1f6a0d4276bf369c6e/raw/1da47924f034d21f87797edbe836abbe7c73dfd5/one.json")
            Response { _ in "https://gist.githubusercontent.com/sbertix/18271e0e549cac1f6a0d4276bf369c6e/raw/1da47924f034d21f87797edbe836abbe7c73dfd5/one.json" }
        } to: {
            Loop(startingAt: $0) {
                Path($0)
                Response(AnyDecodable.self)
            } next: {
                $0.next.string
            }
        }
    }

    func testAsyncStreamSwitch() async throws {
        let reference = switchLoopEndpoint()
        // Test stream (and targettable) reference.
        var count: Int = 0
        var responses: Set<Int> = [1, 2]
        for try await response in reference.resolve(with: .shared) {
            count += 1
            guard let value = response.value.int else { continue }
            responses.remove(value)
        }
        XCTAssertEqual(count, 2)
        XCTAssertTrue(responses.isEmpty)
    }

    func testCombineStreamSwitch() {
        let reference = switchLoopEndpoint()
        // Test stream (and targettable) reference.
        let expectation: XCTestExpectation = .init()
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = 2
        let responses: NSMutableSet = .init(set: [1, 2])
        reference.resolve(with: .shared)
            .compactMap { $0.value.int }
            .replaceError(with: 0)
            .sink { responses.remove($0); expectation.fulfill() }
            .store(in: &bin)
        wait(for: [expectation], timeout: 15)
        XCTAssertEqual(responses.count, 0)
    }
}
