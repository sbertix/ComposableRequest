@testable import ComposableRequest
import XCTest

final class ComposableRequestResponseTests: XCTestCase {
    /// Test responses.
    func testResponse() {
        let value = [["Integer": 1,
                      "camel_case_string": "",
                      "bool": true,
                      "none": NSNull(),
                      "double": 2.0,
                      "url": "https://google.com"]]
        let data = try? JSONSerialization.data(withJSONObject: value, options: [])
        let response = data.flatMap { try? Response(data: $0) }
        let first = response?.array()?.first
        XCTAssert(first == response?[0])
        XCTAssert(first?.integer.int() == 1, "Int is not `Int`.")
        XCTAssert(first?.camelCaseString.string() == "", "String is not `String`.")
        XCTAssert(first?["bool"].bool() == true, "Bool is not `Bool`.")
        XCTAssert(Response.string("y").bool() == true)
        XCTAssert(Response.string("f").bool() == false)
        XCTAssert(first?.none == Response.none, "None is not `None`.")
        XCTAssert(Response(value).any() is [[String: Any]], "Check `any`")
        XCTAssert(first?.beautifiedDescription.isEmpty == false, "Beautified description doesn't check out.")
        XCTAssert(first?.dictionary()?["double"]?.double() == 2, "`Double` is not `Double`.")
        XCTAssert(first?["url"].url() != nil, "`URL` is not `URL`.")
        _ = try? XCTAssert(Response(Response(["key": "value"]).data()).key.string() == "value", "`Data` is not `Data`.")
    }

    static var allTests = [
        ("Response", testResponse)
    ]
}
