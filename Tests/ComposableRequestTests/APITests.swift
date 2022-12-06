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
    // MARK: Builder

    func testBuilder() {
        // Prepare the components.
        @EndpointBuilder func components(_ flag: Bool) -> Single<DefaultResponse> {
            if #available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *) {
                Method(.post)
            }
            Path("https://google.com")
            Path("it")
            if flag {
                Query("value", forKey: "key")
                Query("value", forKey: "key2")
                Headers("value", forKey: "key")
                Headers("value", forKey: "key2")
            } else {
                Query("wrong", forKey: "wrongKey")
            }
            if true {
                Body(.init())
                Service(.background)
                Cellular(false)
                Timeout(15)
                Constrained(false)
                Expensive(false)
            }
        }
        // Test the request.
        let endpoint = components(true)
        // swiftlint:disable:next force_unwrapping
        let request = URLRequest(path: endpoint.path, components: endpoint.components)!
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.absoluteString, "https://google.com/it?key=value&key2=value")
        XCTAssertEqual(request.allHTTPHeaderFields, ["key": "value", "key2": "value"])
        XCTAssertEqual(request.httpBody, .init())
        XCTAssertEqual(request.networkServiceType, .background)
        XCTAssertEqual(request.allowsCellularAccess, false)
        XCTAssertEqual(request.timeoutInterval, 15)
        XCTAssertEqual(request.allowsConstrainedNetworkAccess, false)
        XCTAssertEqual(request.allowsExpensiveNetworkAccess, false)
    }

    // MARK: Generic

    private func wait<P: Publisher>(
        for publisher: P,
        timeout: TimeInterval = 10,
        count: Int = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> [P.Output] {
        // Prepare the response.
        var result: Result<[P.Output], any Error>?
        let expectation: XCTestExpectation = .init()
        let cancellable = publisher
            .collect()
            .sink {
                defer { expectation.fulfill() }
                guard case .failure(let error) = $0 else { return }
                result = .failure(error)
            } receiveValue: {
                XCTAssertEqual($0.count, count, file: file, line: line)
                result = .success($0)
            }
        // Wait for the publisher to complete.
        wait(for: [expectation], timeout: timeout)
        cancellable.cancel()
        return try XCTUnwrap(
            result,
            file: file,
            line: line
        ).get()
    }

    private func test<S: SingleEndpoint>(
        expecting output: S.Output,
        file: StaticString = #file,
        line: UInt = #line,
        recursive: Bool = true,
        @EndpointBuilder endpoint: () -> S
    ) async throws where S.Output: Equatable {
        try await test(expecting: output, file: file, line: line, compare: { $0 }, endpoint: endpoint)
    }

    private func test<S: SingleEndpoint, E: Equatable>(
        expecting output: E,
        file: StaticString = #file,
        line: UInt = #line,
        compare: (S.Output) -> E,
        @EndpointBuilder endpoint: () -> S
    ) async throws {
        let endpoint = endpoint()
        var responses: [S.Output] = []
        // Structured concurrency.
        responses.append(try await endpoint.resolve(with: .shared))
        XCTAssertEqual(responses.map(compare), [output])
        responses.removeAll()
        for try await response in endpoint._resolve(with: .shared) { responses.append(response) }
        XCTAssertEqual(responses.map(compare), [output])
        responses.removeAll()
        // Combine.
        responses = try wait(for: endpoint.resolve(with: .shared))
        XCTAssertEqual(responses.map(compare), [output])
        responses.removeAll()
        responses = try wait(for: endpoint._resolve(with: .shared))
        XCTAssertEqual(responses.map(compare), [output])
        responses.removeAll()
        // Any endpoints.
        guard !(endpoint is AnySingleEndpoint<S.Output>) else {
            // Any loop any single endpoint.
            try await test(expecting: [output], file: file, line: line, compare: compare) {
                endpoint.eraseToAnyLoopEndpoint()
            }
            return
        }
        // Any single endpoint.
        try await test(expecting: output, file: file, line: line, compare: compare) {
            endpoint.eraseToAnySingleEndpoint()
        }
        // Any loop endpoint.
        try await test(expecting: [output], file: file, line: line, compare: compare) {
            endpoint.eraseToAnyLoopEndpoint()
        }
    }

    private func test<L: LoopEndpoint>(
        expecting output: [L.Output],
        file: StaticString = #file,
        line: UInt = #line,
        @EndpointBuilder _ endpoint: () -> L
    ) async throws where L.Output: Equatable {
        try await test(expecting: output, file: file, line: line, compare: { $0 }, endpoint: endpoint)
    }

    private func test<L: LoopEndpoint, E: Equatable>(
        expecting output: [E],
        file: StaticString = #file,
        line: UInt = #line,
        compare: (L.Output) -> E,
        @EndpointBuilder endpoint: () -> L
    ) async throws {
        let endpoint = endpoint()
        var responses: [L.Output] = []
        // Structured concurrency.
        for try await response in endpoint.resolve(with: .shared) { responses.append(response) }
        XCTAssertEqual(responses.map(compare), output)
        responses.removeAll()
        for try await response in endpoint._resolve(with: .shared) { responses.append(response) }
        XCTAssertEqual(responses.map(compare), output)
        responses.removeAll()
        // Combine.
        responses = try wait(for: endpoint.resolve(with: .shared), count: output.count)
        XCTAssertEqual(responses.map(compare), output)
        responses.removeAll()
        responses = try wait(for: endpoint._resolve(with: .shared), count: output.count)
        XCTAssertEqual(responses.map(compare), output)
        responses.removeAll()
        // Cancel combine.
        if output.count > 1 {
            responses = try wait(for: endpoint.resolve(with: .shared).prefix(1), count: 1)
            XCTAssertEqual(responses.prefix(1).map(compare), .init(output.prefix(1)))
            responses.removeAll()
            responses = try wait(for: endpoint._resolve(with: .shared).prefix(1), count: 1)
            XCTAssertEqual(responses.prefix(1).map(compare), .init(output.prefix(1)))
            responses.removeAll()
        }
        // Any loop endpoint.
        guard !(endpoint is AnyLoopEndpoint<L.Output>) else { return }
        try await test(expecting: output, file: file, line: line, compare: compare) {
            endpoint.eraseToAnyLoopEndpoint()
        }
    }

    // MARK: Singles

    func testSingle() async throws {
        try await test(expecting: 1) {
            Path("https://gist.githubusercontent.com")
            Path("sbertix")
            Path("18271e0e549cac1f6a0d4276bf369c6e")
            Path("raw")
            Path("1da47924f034d21f87797edbe836abbe7c73dfd5")
            Path("one.json")
            Response(AnyDecodable.self)
            Response<AnyDecodable, _>(\.value.int!)
        }
    }

    func testSingleMap() async throws {
        try await test(expecting: 1) {
            Map {
                Path("https://gist.githubusercontent.com")
                Path("sbertix")
                Path("18271e0e549cac1f6a0d4276bf369c6e")
                Path("raw")
                Path("1da47924f034d21f87797edbe836abbe7c73dfd5")
                Path("one.json")
                Response(AnyDecodable.self)
            } to: {
                $0.value.int
            }
        }
    }

    func testSingleFlatMap() async throws {
        try await test(expecting: 2) {
            FlatMap {
                Path("https://gist.githubusercontent.com")
                Path("sbertix")
                Path("18271e0e549cac1f6a0d4276bf369c6e")
                Path("raw")
                Path("1da47924f034d21f87797edbe836abbe7c73dfd5")
                Path("one.json")
                Response(AnyDecodable.self)
                Response<AnyDecodable, _>(\.next.string!)
            } to: {
                Path($0)
                Response(AnyDecodable.self)
                Response<AnyDecodable, _>(\.value.int!)
            }
        }
    }

    func testSingleCatch() async throws {
        try await test(expecting: 1) {
            Static(error: EndpointError.invalidRequest).catch { _ in
                Static(1)
            }
        }
    }

    func testFirst() async throws {
        try await test(expecting: 1) {
            Loop(startingAt: "one.json") {
                Path("https://gist.githubusercontent.com")
                Path("sbertix")
                Path("18271e0e549cac1f6a0d4276bf369c6e")
                Path("raw")
                Path("1da47924f034d21f87797edbe836abbe7c73dfd5")
                Path($0)
                Response(AnyDecodable.self)
                Response<AnyDecodable, _>(\.value.int)
            } next: { _ in
                .repeat
            }.first()
        }
    }

    func testLast() async throws {
        try await test(expecting: 2) {
            $0.value.int
        } endpoint: {
            Loop(startingAt: "one.json") {
                Path("https://gist.githubusercontent.com")
                Path("sbertix")
                Path("18271e0e549cac1f6a0d4276bf369c6e")
                Path("raw")
                Path("1da47924f034d21f87797edbe836abbe7c73dfd5")
                Path($0)
                Response(AnyDecodable.self)
            } next: {
                ($0.next.string?.components(separatedBy: "/").last).flatMap(NextAction.advance) ?? .break
            }.last()
        }
    }

    func testCollect() async throws {
        try await test(expecting: [1, 2]) {
            $0.compactMap(\.value.int)
        } endpoint: {
            Loop(startingAt: "one.json") {
                Path("https://gist.githubusercontent.com")
                Path("sbertix")
                Path("18271e0e549cac1f6a0d4276bf369c6e")
                Path("raw")
                Path("1da47924f034d21f87797edbe836abbe7c73dfd5")
                Path($0)
                Response(AnyDecodable.self)
            } next: {
                ($0.next.string?.components(separatedBy: "/").last).flatMap(NextAction.advance) ?? .break
            }.collect()
        }
    }

    // MARK: Loops

    func testLoop() async throws {
        try await test(expecting: [1, 2]) {
            $0.value.int
        } endpoint: {
            Loop(startingAt: "one.json") {
                Path("https://gist.githubusercontent.com")
                Path("sbertix")
                Path("18271e0e549cac1f6a0d4276bf369c6e")
                Path("raw")
                Path("1da47924f034d21f87797edbe836abbe7c73dfd5")
                Path($0)
                Response(AnyDecodable.self)
            } next: {
                ($0.next.string?.components(separatedBy: "/").last).flatMap(NextAction.advance) ?? .break
            }
        }
    }

    func testLoopMap() async throws {
        try await test(expecting: [1, 2]) {
            Loop(startingAt: "one.json") {
                Path("https://gist.githubusercontent.com")
                Path("sbertix")
                Path("18271e0e549cac1f6a0d4276bf369c6e")
                Path("raw")
                Path("1da47924f034d21f87797edbe836abbe7c73dfd5")
                Path($0)
                Response(AnyDecodable.self)
            } next: {
                ($0.next.string?.components(separatedBy: "/").last).flatMap(NextAction.advance) ?? .break
            }.map {
                $0.value.int
            }
        }
    }

    func testLoopFlatMap() async throws {
        try await test(expecting: [1, 2]) {
            $0.value.int
        } endpoint: {
            FlatMap {
                Path("https://gist.githubusercontent.com")
                Path("sbertix")
                Path("18271e0e549cac1f6a0d4276bf369c6e")
                Path("raw")
                Path("1da47924f034d21f87797edbe836abbe7c73dfd5")
                Path("one.json")
                Response { _ in "one.json" }
            } to: {
                Loop(startingAt: $0) {
                    Path("https://gist.githubusercontent.com")
                    Path("sbertix")
                    Path("18271e0e549cac1f6a0d4276bf369c6e")
                    Path("raw")
                    Path("1da47924f034d21f87797edbe836abbe7c73dfd5")
                    Path($0)
                    Response(AnyDecodable.self)
                } next: {
                    ($0.next.string?.components(separatedBy: "/").last).flatMap(NextAction.advance) ?? .break
                }
            }
        }
    }

    func testLoopCatch() async throws {
        try await test(expecting: [1]) {
            Static(error: EndpointError.invalidRequest)
                .eraseToAnyLoopEndpoint()
                .catch { _ in
                    Static(1)
                }
        }
    }

    func testPrefix() async throws {
        try await test(expecting: [1, 2, 3, 4, 5]) {
            Loop(startingAt: 1) {
                Static($0)
            } next: {
                .advance(to: $0 + 1)
            }.prefix(5)
        }
    }
}
