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
            .task(by: .ephemeral) {
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
        request.locking {
            XCTAssert($0.key.userInfo["key"] == "value")
            return $0.request.header(HTTPCookie.requestHeaderFields(with: $0.key.cookies))
        }
        .expecting(String.self)
        .append("Test.json")
        .unlocking(with: .init(cookies: [HTTPCookie(properties: [.name: "key",
                                                                 .value: "value",
                                                                 .path: "/",
                                                                 .domain: "test.com"])!],
                               userInfo: ["key": "value"]))
        .debugTask {
            switch $0.value {
            case .success(let response): XCTAssert(response.contains("A random string."))
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
        .task(maxLength: .max, onComplete: {
            XCTAssert(offset == $0 && $0 == 4)
            expectation.fulfill()
        }) { _ in }
            .resume()
        wait(for: [expectation], timeout: 20)
    }
    
    /// Test step-wise `Paginated`.
    func testStepwisePaginated() {
        let expectations = [XCTestExpectation(description: "A"),
                            XCTestExpectation(description: "B"),
                            XCTestExpectation(description: "C"),
                            XCTestExpectation(description: "D")]
        let languages = ["it", "de", "fr"]
        let requester = Requester(configuration: Requester.Configuration()
            .sessionConfiguration(.default)
            .dispatcher(.init())
            .waiting(0...0))
        var offset = 0
        // prepare request.
        let request = Request("https://instagram.com")
            .paginating(key: "l",
                        initial: "en",
                        next: { _ in offset < languages.count ? languages[offset] : nil })
            .task(maxLength: 1, by: requester) { _ in expectations[offset].fulfill(); offset += 1 }
            .resume()
        // wait for it.
        wait(for: [expectations[0]], timeout: 10)
        request?.resume()
        wait(for: [expectations[1]], timeout: 10)
        request?.resume()
        wait(for: [expectations[2]], timeout: 10)
        XCTAssert(request?.next != nil)
        request?.resume()
        wait(for: [expectations[3]], timeout: 10)
        XCTAssert(request?.next == nil)
    }
    
    /// Test `Paginated` together with `Lock`.
    func testPaginatedLock() {
        let expectation = XCTestExpectation()
        let languages = ["it", "de", "fr"]
        var offset = 0
        let request = Request(URL(string: "https://instagram.com")!)
        var locked = request.paginating(key: "key", initial: "value") { _ in "next" }
            .locking(authenticator: Unlocking.concat(\.header))
        locked = locked.key("l").initial("en")
        locked.next = { _ in nil }
        XCTAssert(locked.key == "l")
        XCTAssert(locked.initial == "en")
        XCTAssert(locked.next(.success(.empty)) == nil)
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
        .unlocking(with: Key(cookies: []))
        .debugTask(maxLength: .max, onComplete: {
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
            .locking { $0.request.header(HTTPCookie.requestHeaderFields(with: $0.key.cookies)) }
        locked = locked.key("l").initial("en")
        locked.next = { _ in nil }
        XCTAssert(locked.key == "l")
        XCTAssert(locked.initial == "en")
        XCTAssert(locked.next(.success(.empty)) == nil)
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
        .unlocking(with: Key(cookies: []))
        .debugTask(maxLength: .max, onComplete: {
            XCTAssert(offset == $0 && $0 == 4)
            expectation.fulfill()
        }) { _ in }
            .resume()
        wait(for: [expectation], timeout: 20)
    }
    
    /// Test cancel request.
    func testCancel() {
        let cancelExpectation = XCTestExpectation()
        let successExpectation = XCTestExpectation()
        // request it.
        let task = Request("http://deelay.me/100/http://google.com")
            .task {
                switch $0 {
                case .success:
                    successExpectation.fulfill()
                case .failure(let error):
                    XCTAssert(String(describing: error).contains("-999"))
                    cancelExpectation.fulfill()
                }
            }.resume()
        // cancel it.
        task?.cancel()
        wait(for: [cancelExpectation], timeout: 5)
        // resume it again.
        DispatchQueue.main.asyncAfter(deadline: .now()+1) { task?.resume() }
        wait(for: [successExpectation], timeout: 10)
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
        ("Expecting.StepwisePaginated", testStepwisePaginated),
        ("Expecting.Paginated.Lock", testPaginatedLock),
        ("Expecting.Paginated.CustomLock", testPaginatedCustomLock),
        ("Request.Deinit", testDeinit),
        ("Request.Cancel", testCancel),
        ("Request.Method", testMethod)
    ]
}
