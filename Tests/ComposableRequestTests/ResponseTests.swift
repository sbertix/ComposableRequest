@testable import ComposableRequest
import XCTest

final class ComposableRequestResponseTests: XCTestCase {
    /// Test responses.
    func testResponse() {
        let value = [["integer": 1,
                      "null": NSNull(),
                      "camel_case_string": "",
                      "bool": true,
                      "double": 2.3,
                      "url": "https://google.com"]]
        let data = try! JSONEncoder().encode(Response(value))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        var response = try! decoder.decode(Response.self, from: data)
        let first = response.array()?.first
        XCTAssert(first == response[0])
        XCTAssert(first?.integer.int() == 1, "Int is not `Int`.")
        XCTAssert(first?.camelCaseString.string() == "", "String is not `String`.")
        XCTAssert(first?["bool"].bool() == true, "Bool is not `Bool`.")
        XCTAssert(Response("y").bool() == true)
        XCTAssert(Response("f").bool() == false)
        XCTAssert(first?.dictionary()?["double"]?.double() == 2.3, "`Double` is not `Double`.")
        XCTAssert(first?["url"].url() != nil, "`URL` is not `URL`.")
        // check literals.
        response = nil
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
        response = [1, Response(2)]
        XCTAssert(response[1].int() == 2)
        response = 1000
        XCTAssert(response.date()?.timeIntervalSince1970 == 1000)
        response = .empty
        XCTAssert(response == nil)
        XCTAssert(response.debugDescription == "Response(<null>)")
        // check equality.
        value.first?.forEach { _, value in XCTAssert(Response(value) == Response(value)) }
    }

    static var allTests = [
        ("Response", testResponse)
    ]
}
