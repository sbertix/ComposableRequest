//
//  ComposableTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import XCTest

@testable import Requests

internal final class ExtensionsTests: XCTestCase {
    /// Test `ComposableOptionalType`.
    func testComposableOptionalType() {
        XCTAssert(Int?.none.composableIsNone == true)
        XCTAssert(Int?.some(0).composableIsNone == false)
        XCTAssert(Int?.none.composableFlatMap { $0 + 1 }.composableIsNone == true)
        XCTAssert(Int?.some(0).composableFlatMap { $0 + 1 } == 1)
        XCTAssert(Int?.some(0).composableOptional == 0)
        XCTAssert(Int?.composableNone.composableIsNone)
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

    /// Test reference.
    func testReference() {
        let atomic: Atomic<Int> = .init(1)
        atomic.mutate { $0 = 2 }
        XCTAssertEqual(atomic.value, 2)
    }

    /// Test `String` extensions.
    func testString() {
        XCTAssert("camel_cased".camelCased == "camelCased")
        XCTAssert("snakeCased".snakeCased == "snake_cased")
        XCTAssert("begin".beginningWithUppercase == "Begin")
        XCTAssert("BEGIN".beginningWithLowercase == "bEGIN")
    }
}
