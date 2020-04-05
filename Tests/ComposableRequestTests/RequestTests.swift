@testable import ComposableRequest
import XCTest

final class ProtocolTests: XCTestCase {
    let url = URL(string: ["https://gist.githubusercontent.com/sbertix/",
                           "8959f2534f815ee3f6018965c6c5f9e2/raw/",
                           "c38d855d9aac95fb095b6c5fc75f9a0219183648/Test.json"].joined())!

    /// Test `Method` .
    func testMethod() {
        XCTAssert(Request.Method.get.resolve(using: Data()) == "GET")
        XCTAssert(Request.Method.post.resolve(using: nil) == "POST")
        XCTAssert(Request.Method.default.resolve(using: nil) == "GET")
        XCTAssert(Request.Method.default.resolve(using: Data()) == "GET")
        XCTAssert(Request.Method.default.resolve(using: "test".data(using: .utf8)) == "POST")
    }

    /// Test `Expected`.
    func testExpected() {
        let expectation = XCTestExpectation()
        let request = Request(url)
        request.expecting(Data.self)
            .task(by: Requester.default.ephemeral()) {
                switch $0 {
                case .success(let data): XCTAssert(String(data: data, encoding: .utf8)!.contains("A random string."))
                case .failure(let error): XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            }
            .resume()
        wait(for: [expectation], timeout: 3)
    }

    /// Test `Expected` together with `Lock`.
    func testExpectedLock() {
        let expectation = XCTestExpectation()
        let request = Request(url.deletingLastPathComponent())
        request.locking { $0.header($1.headerFields).body($1.body) }
            .expecting(String.self)
            .append("Test.json")
            .authenticating(with: AnySecret(AnySecret(headerFields: ["": "empty.keys.are.not.added"], body: [:])))
            .locking(into: Lock.self)
            .authenticating(with: AnySecret(headerFields: ["": "another.empty.key.that.will.be.trashed"], body: [:]))
            .debugTask {
                switch $0 {
                case .success(let response): XCTAssert(response.data.contains("A random string."))
                case .failure(let error): XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            }
            .resume()
        wait(for: [expectation], timeout: 3)
    }

    /// Test `Paginated`.
    func testPaginated() {
        struct Lossless: LosslessStringConvertible {
            let description: String = "instagram"
            init() { }
            init?(_ description: String) { }
        }

        let expectation = XCTestExpectation()
        let languages = ["it", "de", "fr"]
        var offset = 0
        let request = Request(URL(string: "https://instagram.com")!)
        request
            .append(Lossless())
            .paginating(key: "l", initial: "en") { _ in nil }
            .expecting(String.self) { _ in
                defer { offset += 1 }
                return offset < languages.count ? languages[offset] : nil
            }
            .cycleTask(onComplete: {
                XCTAssert(offset == $0 && $0 == 4)
                expectation.fulfill()
            }) { _ in }
            .resume()
        wait(for: [expectation], timeout: 20)
    }

    /// Test `Paginated` together with `Lock`.
    func testPaginatedLock() {
        let expectation = XCTestExpectation()
        let languages = ["it", "de", "fr"]
        var offset = 0
        let request = Request(url: URL(string: "https://instagram.com")!)
        var locked = request.paginating(key: "key", initial: "value") { _ in "next" }
            .locking(into: Lock.self)
        locked = locked.key("l").initial("en")
        locked.next = { _ in nil }
        XCTAssert(locked.key == "l")
        XCTAssert(locked.initial == "en")
        XCTAssert(locked.next(.success(nil)) == nil)
        locked
            .instagram
            .query("", value: nil)
            .query([URLQueryItem(name: "", value: nil)])
            .header("", value: nil)
            .body("", value: nil)
            .body(.parameters([:]))
            .method(.get)
            .expecting(String.self) { _ in
                defer { offset += 1 }
                return offset < languages.count ? languages[offset] : nil
            }
            .authenticating(with: AnySecret(headerFields: [:], body: [:]))
            .debugCycleTask(onComplete: {
                XCTAssert(offset == $0 && $0 == 4)
                expectation.fulfill()
            }) { _ in }
            .resume()
        wait(for: [expectation], timeout: 20)
    }
    
    /// Test `Paginated` together with `CustomLock`.
    func testPaginatedCustomLock() {
        let expectation = XCTestExpectation()
        let languages = ["it", "de", "fr"]
        var offset = 0
        let request = Request("https://instagram.com")
        var locked = request.paginating(key: "key", initial: "value") { _ in "next" }
            .locking { $0.header($1.headerFields).body($1.body) }
        locked = locked.key("l").initial("en")
        locked.next = { _ in nil }
        XCTAssert(locked.key == "l")
        XCTAssert(locked.initial == "en")
        XCTAssert(locked.next(.success(nil)) == nil)
        locked
            .instagram
            .query("", value: nil)
            .query([URLQueryItem(name: "", value: nil)])
            .header("", value: nil)
            .body("", value: nil)
            .body(.parameters([:]))
            .method(.get)
            .expecting(String.self) { _ in
                defer { offset += 1 }
                return offset < languages.count ? languages[offset] : nil
            }
            .authenticating(with: AnySecret(headerFields: [:], body: [:]))
            .debugCycleTask(onComplete: {
                XCTAssert(offset == $0 && $0 == 4)
                expectation.fulfill()
            }) { _ in }
            .resume()
        wait(for: [expectation], timeout: 20)
    }


    /// Test cancel request.
    func testCancel() {
        Request(url)
            .task {
                switch $0 {
                case .success: XCTFail("It shouldn't succeed.")
                case .failure(let error): XCTAssert(String(describing: error).contains("-999"))
                }
            }
            .resume()?
            .cancel()
    }

    /// Test `deinit` `Requester`.
    func testDeinit() {
        let expectation = XCTestExpectation()
        var requester: Requester? = Requester()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            requester = nil
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        XCTAssert(requester == nil)
    }

    static var allTests = [
        ("Expenting.Expected", testExpected),
        ("Expecting.Expected.Lock", testExpectedLock),
        ("Expecting.Paginated", testPaginated),
        ("Expecting.Paginated.Lock", testPaginatedLock),
        ("Expecting.Paginated.CustomLock", testPaginatedCustomLock),
        ("Request.Deinit", testDeinit),
        ("Request.Cancel", testCancel),
        ("Request.Method", testMethod)
    ]
}
