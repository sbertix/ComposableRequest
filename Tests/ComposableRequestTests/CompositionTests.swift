//
//  CompositionTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import XCTest

@testable import ComposableRequest

/// A `class` defining tests for composition `protocol`s.
internal final class CompositionTests: XCTestCase {
    /// Test `Body`.
    func testBody() throws {
        /// The actual test.
        func test(_ item: Body) {
            // Replacing.
            XCTAssert("test".data(using: .utf8).flatMap(item.body)?.body?.isEmpty == false)
            XCTAssert(try item.body([3]).body.flatMap(Wrapper.decode)?.array()?.first?.int() == 3)
            XCTAssert(item.body(["key": "value"]).body.flatMap { String(data: $0, encoding: .utf8) } == "key=value")
            XCTAssert(item.body("value", forKey: "key")
                        .body
                        .flatMap { String(data: $0, encoding: .utf8) } == "key=value")
            // Updating.
            let copy = item.body(["key": "value"])
            XCTAssert(copy
                        .body(appending: "value", forKey: "key2")
                        .body(appending: "value2", forKey: "key")
                        .body
                        .flatMap { String(data: $0, encoding: .utf8) }
                        .flatMap { $0.contains("key=value2") && $0.contains("key2=value") } ?? false)
        }

        let request = Request("https://google.com")
        test(request)
        test(request as Body)
    }

    /// Test `Header`.
    func testHeader() {
        /// The actual test.
        func test(_ item: Header) {
            // Replacing.
            XCTAssert(item.header(["key": "value"]).header["key"] == "value")
            XCTAssert(item.header(["key": nil]).header["key"] == nil)
            XCTAssert(item.header(["key": .some("value")]).header["key"] == "value")
            XCTAssert(item.header("value", forKey: "key").header["key"] == "value")
            // Updating.
            let copy = item.header(["key": "value"])
            XCTAssert(copy
                        .header(appending: "value", forKey: "key2")
                        .header(appending: "value2", forKey: "key")
                        .header
                        .sorted { $0.key < $1.key }
                        .map(\.value)
                        .joined(separator: ",") == "value2,value")
            XCTAssert(copy.header(appending: ["key": nil]).header["key"] == nil)
        }

        let request = Request("https://google.com")
        test(request)
        test(request as Header)
    }

    /// Test `Method`.
    func testMethod() {
        XCTAssert(HTTPMethod.get.rawValue == "GET")
        XCTAssert(HTTPMethod.header.rawValue == "HEADER")
        XCTAssert(HTTPMethod.post.rawValue == "POST")
        XCTAssert(HTTPMethod.put.rawValue == "PUT")
        XCTAssert(HTTPMethod.delete.rawValue == "DELETE")
        XCTAssert(HTTPMethod.connect.rawValue == "CONNECT")
        XCTAssert(HTTPMethod.options.rawValue == "OPTIONS")
        XCTAssert(HTTPMethod.trace.rawValue == "TRACE")
        XCTAssert(HTTPMethod.patch.rawValue == "PATCH")
        XCTAssert(HTTPMethod.default.rawValue.isEmpty)

        /// The actual test.
        func test(_ item: ComposableRequest.Method) {
            XCTAssert(item.method(.connect).method == .connect)
        }

        let request = Request("https://google.com")
        test(request)
        test(request as ComposableRequest.Method)
    }

    /// Test `Path`.
    func testPath() {
        /// The actual test.
        func test(_ item: Path) {
            XCTAssert(item.path(appending: "test").components?.url?.lastPathComponent == "test")
        }

        let request = Request("https://google.com")
        test(request)
        test(request as Path)
    }

    /// Test `Query`.
    func testQuery() {
        /// The actual test.
        func test(_ item: Query) {
            // Replacing.
            XCTAssert(item.query([URLQueryItem(name: "key", value: "value")])
                        .components?
                        .queryItems?
                        .first
                        .flatMap { "\($0.name)=\($0.value ?? "")" } == "key=value")
            XCTAssert(item.query(["key": "value"])
                        .components?
                        .queryItems?
                        .first
                        .flatMap { "\($0.name)=\($0.value ?? "")" } == "key=value")
            XCTAssert(item.query(["key": .some("value")])
                        .components?
                        .queryItems?
                        .first
                        .flatMap { "\($0.name)=\($0.value ?? "")" } == "key=value")
            XCTAssert(item.query(["key": nil])
                        .components?
                        .queryItems == nil)
            // Updating.
            let copy = item.query(["key": "value"])
            XCTAssert(copy.query(appending: [URLQueryItem(name: "key2", value: "value2")])
                        .components?
                        .queryItems?
                        .sorted { $0.name < $1.name }
                        .compactMap(\.value)
                        .joined(separator: ",") == "value,value2")
            XCTAssert(copy.query(appending: ["key2": "value",
                                             "key": "value2"])
                        .components?
                        .queryItems?
                        .sorted { $0.name < $1.name }
                        .compactMap(\.value)
                        .joined(separator: ",") == "value2,value")
            XCTAssert(copy.query(appending: ["key2": "value",
                                             "key": nil])
                        .components?
                        .queryItems?
                        .sorted { $0.name < $1.name }
                        .compactMap(\.value)
                        .joined(separator: ",") == "value")
        }

        let request = Request("https://google.com")
        test(request)
        test(request as Query)
    }

    /// Test `Timeout`.
    func testTimeout() {
        /// The actual test.
        func test(_ item: Timeout) {
            XCTAssert(item.timeout(after: 5).timeout == 5)
        }

        let request = Request("https://google.com")
        test(request)
        test(request as Timeout)
    }
}
