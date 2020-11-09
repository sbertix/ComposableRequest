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

@testable import ComposableRequest

/// A `class` defining all models test cases.
final class WrappersTests: XCTestCase {
    /// A `struct` defining a custom `Wrapped`.
    struct Wrapped: ComposableRequest.Wrapped {
        /// The underlying wrapper.
        var wrapper: () -> Wrapper
        
        /// Init.
        ///
        /// - parameter wrapper: A valid closure.
        init(wrapper: @escaping () -> Wrapper) { self.wrapper = wrapper }
    }

    /// Test `Wrappable`.
    func testWrappable() {
        XCTAssert(true.wrapped.bool() == true)
        XCTAssert(1.wrapped.int() == 1)
        XCTAssert(Float(2.1).wrapped.double().flatMap(Float.init) == 2.1)
        XCTAssert(Double(2.1).wrapped.double() == 2.1)
        XCTAssert("test".wrapped.string() == "test")
        XCTAssert(NSNull().wrapped.isEmpty)
        XCTAssert((Int?.none).wrapped.isEmpty == true)
        XCTAssert(Int?.some(2)?.wrapped.int() == 2)
        XCTAssert(["test"].wrapped.array() == ["test"])
        XCTAssert(["key": "value"].wrapped.dictionary() == ["key": "value"])
        XCTAssert(1.wrapped.wrapped.int() == 1)
        #if canImport(CoreGraphics)
        XCTAssert(CGFloat(2.1).wrapped.double() == 2.1)
        #endif
    }
    
    /// Test `Wrapped`.
    func testWrapped() {
        let array = Wrapped(wrapper: [["key": 2]])
        XCTAssert(array[0].dictionary() == ["key": 2])
        XCTAssert((try? JSONDecoder().decode(Wrapped.self, from: JSONEncoder().encode(array)))?[0].dictionary() == ["key": 2])
        let dictionary = Wrapped(wrapper: ["key": 2])
        XCTAssert(dictionary["key"] == 2)
        XCTAssert(dictionary.key == 2)
    }
    
    /// Test `Wrapper`.
    func testWrapper() {
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
