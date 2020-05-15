//
//  ComposableTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

@testable import ComposableRequest
import XCTest

final class RequestsTests: XCTestCase {
    let url = URL(string: ["https://gist.githubusercontent.com/sbertix/",
                           "8959f2534f815ee3f6018965c6c5f9e2/raw/",
                           "c38d855d9aac95fb095b6c5fc75f9a0219183648/Test.json"].joined())!
    
    /// Test `Method` .
    func testMethod() {
        XCTAssert(Request.Method.get.rawValue == "GET")
        XCTAssert(Request.Method.header.rawValue == "HEADER")
        XCTAssert(Request.Method.post.rawValue == "POST")
        XCTAssert(Request.Method.put.rawValue == "PUT")
        XCTAssert(Request.Method.delete.rawValue == "DELETE")
        XCTAssert(Request.Method.connect.rawValue == "CONNECT")
        XCTAssert(Request.Method.options.rawValue == "OPTIONS")
        XCTAssert(Request.Method.trace.rawValue == "TRACE")
        XCTAssert(Request.Method.patch.rawValue == "PATCH")
    }
    
    /// Test `Expected`.
    func testExpected() {
        let expectation = XCTestExpectation()
        let request = Request(url)
        request
            .prepare { $0 }
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
        request
            .appending(path: "Test.json")
            .prepare { $0.map { String(data: $0, encoding: .utf8) ?? "" }}
            .locking {
                return $0.replacing(header: HTTPCookie.requestHeaderFields(with: $1.cookies))
            }
            .unlocking(with: AnyCookieKey(AnyCookieKey(cookies: [HTTPCookie(properties: [.name: "key",
                                                                             .value: "value",
                                                                             .path: "/",
                                                                             .domain: "test.com"])!])))
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
        let expectation = XCTestExpectation()
        let languages = ["en", "it", "de", "fr"]
        var offset = 0
        let request = Request(URL(string: "https://instagram.com")!)
        request
            .prepare(processor: { $0.map { String(data: $0, encoding: .utf8) ?? "" }},
                     pager: { request, _ in
                        defer { offset += 1 }
                        return offset < languages.count
                            ? request.appending(query: "l", with: languages[offset])
                            : nil
                    })
            .task(maxLength: .max,
                  onComplete: { XCTAssert(offset == $0+1 && $0 == 4); expectation.fulfill() },
                  onChange: { _ in })
            .resume()
        wait(for: [expectation], timeout: 20)
    }
    
    /// Test step-wise `Paginated`.
    func testStepwisePaginated() {
        let expectations = [XCTestExpectation(description: "A"),
                            XCTestExpectation(description: "B"),
                            XCTestExpectation(description: "C"),
                            XCTestExpectation(description: "D")]
        let languages = ["en", "it", "de", "fr"]
        let requester = Requester(configuration: Requester.Configuration()
            .sessionConfiguration(.default)
            .dispatcher(.init())
            .waiting(0...0))
        var offset = 0
        // prepare request.
        let request = Request("https://instagram.com")
            .prepare(processor: { $0.map { String(data: $0, encoding: .utf8) ?? "" }},
                     pager: { request, _ in
                        return offset < languages.count
                            ? request.appending(query: "l", with: languages[offset])
                            : nil
                    })
            .task(maxLength: 1, by: requester) { _ in expectations[offset].fulfill(); offset += 1 }
            .resume()
        // wait for it.
        wait(for: [expectations[0]], timeout: 10)
        request?.resume()
        wait(for: [expectations[1]], timeout: 20)
        request?.resume()
        wait(for: [expectations[2]], timeout: 30)
        XCTAssert(request?.next != nil)
        request?.resume()
        wait(for: [expectations[3]], timeout: 40)
    }
    
    /// Test `Paginated` together with `Lock`.
    func testPaginatedLock() {
        let expectation = XCTestExpectation()
        let languages = ["en", "it", "de", "fr"]
        var offset = 0
        let request = Request(URL(string: "https://instagram.com")!)
        request
            .instagram
            .appending(query: "", with: nil)
            .appending(query: [URLQueryItem(name: "", value: nil)])
            .appending(header: "", with: nil)
            .replacing(body: [], serializationOptions: [])
            .replacing(body: nil)
            .replacing(method: .get)
            .prepare(processor: { $0.map { String(data: $0, encoding: .utf8) ?? "" }},
                     pager: { request, _ in
                        defer { offset += 1 }
                        return offset < languages.count
                            ? request.appending(query: "l", with: languages[offset])
                            : nil
                    })
            .locking()
            .unlocking(with: AnyCookieKey(cookies: []))
            .debugTask(maxLength: .max,
                       onComplete: { XCTAssert(offset == $0+1 && $0 == 4); expectation.fulfill() },
                       onChange: { _ in })
            .resume()
        wait(for: [expectation], timeout: 20)
    }
    
    /// Test `Paginated` together with `CustomLock`.
    func testPaginatedCustomLock() {
        let expectation = XCTestExpectation()
        let languages = ["en", "it", "de", "fr"]
        var offset = 0
        let request = Request("https://instagram.com")
        request
            .instagram
            .appending(query: "", with: nil)
            .appending(query: [URLQueryItem(name: "", value: nil)])
            .replacing(header: "", with: nil)
            .replacing(body: [:])
            .replacing(method: .get)
            .prepare(processor: { $0.map { String(data: $0, encoding: .utf8) ?? "" }},
                     pager: { request, _ in
                        defer { offset += 1 }
                        return offset < languages.count
                            ? request.appending(query: "l", with: languages[offset])
                            : nil
                    })
            .locking(AnyCookieKey.self) { $0.replacing(header: HTTPCookie.requestHeaderFields(with: $1.cookies)) }
            .unlocking(with: AnyCookieKey(cookies: []))
            .debugTask(maxLength: .max,
                       onComplete: { XCTAssert(offset == $0+1 && $0 == 4); expectation.fulfill() },
                       onChange: { _ in })
            .resume()
        wait(for: [expectation], timeout: 20)
    }
    
    /// Test cancel request.
    func testCancel() {
        let cancelExpectation = XCTestExpectation()
        let successExpectation = XCTestExpectation()
        // request it.
        let task = Request("http://deelay.me/100/http://google.com")
            .prepare { $0.map { String(data: $0, encoding: .utf8) ?? "" }}
            .task {
                switch $0 {
                case .success:
                    successExpectation.fulfill()
                case .failure(let error):
                    XCTAssert(String(describing: error).contains("-999"))
                    cancelExpectation.fulfill()
                }
            }
            .resume()
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
