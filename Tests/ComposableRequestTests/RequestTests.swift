//
//  RequestTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 18/08/21.
//

#if canImport(Combine)
import Combine
#endif
import Foundation
import XCTest

@testable import ComposableRequest

internal final class RequestTests: XCTestCase {
    #if canImport(Combine)
    private var bin: Set<AnyCancellable>!
    #endif

    override func setUp() {
        #if canImport(Combine)
        bin = []
        #endif
    }

    #if swift(>=5.5)
    // swiftlint:disable empty_xctest_method
    @available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
    /// Test structured concurrencty.
    func testAsyncRequest() async throws {
        let response = try await Request.endpoint()
            .prepare(with: .async(session: .shared))
            .value
        XCTAssertEqual(response, 2)
    }
    // swiftlint:enable empty_xctest_method
    #endif

    #if canImport(Combine)
    @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
    /// Test combine.
    func testCombineRequest() {
        let expectation = XCTestExpectation()
        Request.endpoint()
            .prepare(with: URLSessionCombineRequester(session: .shared))
            .publisher
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
                expectation.fulfill()
            }, receiveValue: {
                XCTAssertEqual($0, 2)
            })
            .store(in: &bin)
        wait(for: [expectation], timeout: 5)
    }
    #endif

    /// Test completion.
    func testCompletionRequest() {
        let expectation = XCTestExpectation()
        Request.endpoint()
            .prepare(with: URLSessionCompletionRequester(session: .shared))
            .onSuccess({
                XCTAssertEqual($0, 2); expectation.fulfill()
            }, onFailure: {
                XCTFail($0.localizedDescription)
            })
            .resume()
        wait(for: [expectation], timeout: 5)
    }
}

fileprivate extension Request {
    /// The endpoint alias.
    typealias Endpoint<R: Requester> = R.Output.Map<Data>.FlatMap<Wrapper>.Map<Bool>.Switch<R.Output.Map<Int>>

    /// Prepare a random endpoint.
    ///
    /// - returns: Some `Receivable`.
    static func endpoint<R: Requester>() -> Providers.Requester<R, Endpoint<R>> {
        .init { requester in
            Request("https://gist.githubusercontent.com/sbertix/8959f2534f815ee3f6018965c6c5f9e2/raw/ce697fafd1b34ad90cccd9a919a9b0b48574e1ac/Test.json")
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map { $0["string"].string(converting: true) == "A random string." }
                .switch { _ in
                    Request("https://google.com")
                        .prepare(with: requester)
                        .map { _ in 2 }
                }
        }
    }
}
