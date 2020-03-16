@testable import ComposableRequest
import XCTest

final class ComposableRequestExtensionsTests: XCTestCase {
    /// Test `String` extensions.
    func testString() {
        XCTAssert("camel_cased".camelCased == "camelCased")
        XCTAssert("snakeCased".snakeCased == "snake_cased")
        XCTAssert("begin".beginningWithUppercase == "Begin")
        XCTAssert("BEGIN".beginningWithLowercase == "bEGIN")
    }

    /// Test `DataMappable` extensions.
    func testDataMappable() {
        XCTAssert(Data.process(data: Data()) == Data())
    }
    
    /// Test `HTTPCookie` extensions..
    func testCookie() {
        let cookie = HTTPCookie(properties: [.name: "name",
                                             .value: "value",
                                             .domain: "domain",
                                             .path: "path"])!
        XCTAssert(HTTPCookie(data: cookie.data) == cookie)
    }

    static var allTests = [
        ("Extensions.String", testString),
        ("Extensions.Data", testDataMappable),
        ("Extensions.Cookie", testCookie)
    ]
}
