//
//  WrappersTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Foundation
import XCTest

#if canImport(CoreGraphics)
import CoreGraphics
#endif

@testable import Requests

/// A `class` defining all models test cases.
internal final class WrappersTests: XCTestCase {
    func testCodable() throws {
        // Prepare the encoding.
        let encodables: AnyEncodable = .init([
            "boolean": false,
            "float": 3.0,
            "integer": 1,
            "text": "string",
            "listArray": [2, true],
            "listDictionary": ["text": 1]
        ]).toSnakeCase()
        let data = try JSONEncoder().encode(encodables)
        // Prepare the decoding.
        let decoded = try JSONDecoder()
            .decode(AnyDecodable.self, from: data)
            .fromSnakeCase()
        XCTAssertEqual(decoded.boolean.bool, false)
        XCTAssertEqual(decoded.float.double, 3.0)
        XCTAssertEqual(decoded.integer.int, 1)
        XCTAssertEqual(decoded.text.string, "string")
        XCTAssertEqual(decoded.listArray[0].int, 2)
        XCTAssertEqual(decoded.listArray[1].bool, true)
        XCTAssertEqual(decoded.listDictionary.text.int, 1)
    }
}
