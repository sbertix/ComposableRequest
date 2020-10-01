//
//  ComposableTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

@testable import ComposableRequest
import XCTest

final class ResponseTests: XCTestCase {
    /// Test responses.
    func testResponse() {
        let value: Wrapper = [["integer": 1,
                               "null": NSNull().wrapped,
                               "camel_case_string": "",
                               "bool": true,
                               "double": 2.3,
                               "url": "https://google.com"]]
        let data = try! value.encode()
        var response = try! Wrapper.decode(data)
        let first = response.array()?.first
        XCTAssert(first == response[0])
        XCTAssert(first?.integer.int() == 1, "Int is not `Int`.")
        XCTAssert(first?.camelCaseString.string() == "", "String is not `String`.")
        XCTAssert(first?["bool"].bool() == true, "Bool is not `Bool`.")
        XCTAssert(first?.dictionary()?["double"]?.double() == 2.3, "`Double` is not `Double`.")
        XCTAssert(first?["url"].url() != nil, "`URL` is not `URL`.")
        // check literals.
        response = .empty
        XCTAssert(response.description == "<null>")
        response = false
        XCTAssert(response.bool() == false)
        response = ["key": "o\u{306}"]
        XCTAssert(response.key.string() == "o\u{306}")
        response = "test"
        XCTAssert(response.string() == "test")
        response = 2.3
        XCTAssert(response.double() == 2.3)
        response = 2
        XCTAssert(response.int() == 2)
        response = [1, 2]
        XCTAssert(response[1].int() == 2)
        response = 1000
        XCTAssert(response.date()?.timeIntervalSince1970 == 1000)
        response = .empty
    }
}
