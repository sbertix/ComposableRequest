//
//  ComposableTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

@testable import ComposableRequest
import XCTest

internal final class ExtensionsTests: XCTestCase {
    /// Test `String` extensions.
    func testString() {
        XCTAssert("camel_cased".camelCased == "camelCased")
        XCTAssert("snakeCased".snakeCased == "snake_cased")
        XCTAssert("begin".beginningWithUppercase == "Begin")
        XCTAssert("BEGIN".beginningWithLowercase == "bEGIN")
    }

    /// Test `HTTPCookie` extensions..
    func testCookie() throws {
        guard let cookie = CodableHTTPCookie(properties: [.name: "name",
                                                          .value: "value",
                                                          .domain: "domain",
                                                          .path: "path"]) else {
            XCTFail("Invalid cookies")
            return
        }
        let decoded = try JSONDecoder().decode(CodableHTTPCookie.self,
                                               from: JSONEncoder().encode(cookie))
        XCTAssert(decoded == cookie)
    }
}
