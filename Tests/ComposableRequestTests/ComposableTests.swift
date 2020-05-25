//
//  ComposableTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Foundation
import XCTest

@testable import ComposableRequest

final class ComposableTests: XCTestCase {
    // All available tests.
    static var allTests = [
        ("Composable.Body", testBodyComposable),
        ("Composable.Header", testHeaderComposable),
        ("Composable.Method", testMethodComposable),
        ("Composable.Path", testPathComposable),
        ("Composable.Query", testQueryComposable)
    ]
    
    // MARK: Testing
    /// Test `BodyComposable`.
    func testBodyComposable() {
        let request = Request("https://google.com") as BodyComposable
        XCTAssert(
            (request.replacing(body: ["a": "1", "b": "2"]) as? Request)?
                .body
                .flatMap { String(data: $0, encoding: .utf8) }?
                .components(separatedBy: "&")
                .sorted(by: <) == ["a=1", "b=2"]
        )
        XCTAssert(
            (request.replacing(body: ["a": "1", "b": "2"], serializationOptions: []) as? Request)?
                .body
                .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
                .flatMap { $0 as? [String: String] } == ["a": "1", "b": "2"]
        )
    }
    
    /// Test `HeaderComposable`.
    func testHeaderComposable() {
        let request = Request("https://google.com").replacing(header: ["name": "value"]) as HeaderComposable & HeaderParsable
        XCTAssert(
            (request.appending(header: ["name2": "value2", "name": "updated"]) as? Request)?
                .header == ["name": "updated", "name2": "value2"]
        )
        XCTAssert((request.replacing(header: [:]) as? Request)?.header == [:])
        XCTAssert((request.appending(header: "name", with: nil) as? Request)?.header == [:])
        XCTAssert((request.replacing(header: "name3", with: "value3") as? Request)?.header == ["name3": "value3"])
    }
    
    /// Test `MethodComposable`.
    func testMethodComposable() {
        let request = Request("https://google.com") as MethodComposable
        XCTAssert((request.replacing(method: .options) as? Request)?.method == .options)
        XCTAssert((request as? Request)?.method == .default)
    }
    
    /// Test `PathComposable`.
    func testPathComposable() {
        let request = Request("https://google.com") as PathComposable
        XCTAssert(
            (request.appending(path: "test") as? Request)?.request()?.url?.absoluteString == "https://google.com/test"
        )
    }
    
    /// Test `QueryComposable`.
    func testQueryComposable() {
        let request = Request("https://google.com").replacing(query: ["name": "value"]) as QueryComposable & QueryParsable
        XCTAssert(
            (request.appending(query: ["name2": "value2", "name": "updated"]) as? Request)?
                .query == ["name": "updated", "name2": "value2"]
        )
        XCTAssert((request.replacing(query: [:]) as? Request)?.query == [:])
        XCTAssert((request.replacing(query: ["name": nil]) as? Request)?.query == [:])
        XCTAssert((request.replacing(query: ["name3": "value3"]) as? Request)?.query == ["name3": "value3"])
        XCTAssert((request as? Request)?.request()?.url?.absoluteString == "https://google.com?name=value")
    }
}
