//
//  ComposableTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

@testable import ComposableRequest
import XCTest

final class ExtensionsTests: XCTestCase {
    /// Test `String` extensions.
    func testString() {
        XCTAssert("camel_cased".camelCased == "camelCased")
        XCTAssert("snakeCased".snakeCased == "snake_cased")
        XCTAssert("begin".beginningWithUppercase == "Begin")
        XCTAssert("BEGIN".beginningWithLowercase == "bEGIN")
    }

    /// Test `HTTPCookie` extensions..
    func testCookie() {
        let cookie = CodableHTTPCookie(properties: [.name: "name",
                                                    .value: "value",
                                                    .domain: "domain",
                                                    .path: "path"])!
        let decoded = try! JSONDecoder().decode(CodableHTTPCookie.self,
                                                from: JSONEncoder().encode(cookie))
        XCTAssert(decoded == cookie)
    }

    static var allTests = [
        ("Extensions.String", testString),
        ("Extensions.Cookie", testCookie)
    ]
}
