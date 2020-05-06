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
            (request.replace(body: ["a": "1", "b": "2"]) as? Request)?
                .body
                .flatMap { String(data: $0, encoding: .utf8) }?
                .components(separatedBy: "&")
                .sorted(by: <) == ["a=1", "b=2"]
        )
        XCTAssert(
            (request.replace(body: ["a": "1", "b": "2"], serializationOptions: []) as? Request)?
                .body
                .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
                .flatMap { $0 as? [String: String] } == ["a": "1", "b": "2"]
        )
    }
    
    /// Test `HeaderComposable`.
    func testHeaderComposable() {
        let request = Request("https://google.com").replace(header: ["name": "value"]) as HeaderComposable
        XCTAssert(
            (request.append(header: ["name2": "value2", "name": "updated"]) as? Request)?
                .header == ["name": "updated", "name2": "value2"]
        )
        XCTAssert((request.replace(header: [:]) as? Request)?.header == [:])
        XCTAssert((request.append(header: "name", with: nil) as? Request)?.header == [:])
        XCTAssert((request.replace(header: "name3", with: "value3") as? Request)?.header == ["name3": "value3"])
    }
    
    /// Test `MethodComposable`.
    func testMethodComposable() {
        let request = Request("https://google.com") as MethodComposable
        XCTAssert((request.replace(method: .options) as? Request)?.method == .options)
        XCTAssert((request as? Request)?.method == .default)
    }
    
    /// Test `PathComposable`.
    func testPathComposable() {
        let request = Request("https://google.com") as PathComposable
        XCTAssert(
            (request.append(path: "test") as? Request)?.request()?.url?.absoluteString == "https://google.com/test"
        )
    }
    
    /// Test `QueryComposable`.
    func testQueryComposable() {
        let request = Request("https://google.com").replace(query: ["name": "value"]) as QueryComposable
        XCTAssert(
            (request.append(query: ["name2": "value2", "name": "updated"]) as? Request)?
                .query == ["name": "updated", "name2": "value2"]
        )
        XCTAssert((request.replace(query: [:]) as? Request)?.query == [:])
        XCTAssert((request.append(query: "name", with: nil) as? Request)?.query == [:])
        XCTAssert((request.replace(query: "name3", with: "value3") as? Request)?.query == ["name3": "value3"])
        XCTAssert((request as? Request)?.request()?.url?.absoluteString == "https://google.com?name=value")
    }
}
