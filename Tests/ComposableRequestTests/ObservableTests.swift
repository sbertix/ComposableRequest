//
//  ObservableTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import XCTest

@testable import ComposableRequest

/// A url to a json resource.
fileprivate let url = URL(string: ["https://gist.githubusercontent.com/sbertix/",
                                   "8959f2534f815ee3f6018965c6c5f9e2/raw/",
                                   "c38d855d9aac95fb095b6c5fc75f9a0219183648/Test.json"].joined())!

/// A `class` defining a series of tests on `Observable`s.
final class ObservableTests: XCTestCase {
    /// The combine runtime alert.
    private static let runtime: Void = {
        print("Combine runtime: "+(ProcessInfo.processInfo.environment["CX_COMBINE_IMPLEMENTATION"] ?? "combine"))
        return ()
    }()
    /// The dispose bag.
    private var bin: Set<AnyCancellable> = []
    
    /// Set up.
    override func setUp() {
        bin.removeAll()         // This should already been taken care of.
        Logger.default = .none  // This should already been taken care of.
        ObservableTests.runtime
    }
    
    // MARK: Simple
    
    /// Test a generic future request.
    func testFuture() {
        let expectations = ["output", "completion"].map(XCTestExpectation.init)
        LockSessionProvider { url, session in
            Deferred {
                Just(url.deletingLastPathComponent())
                    .setFailureType(to: Error.self)
                    .flatMap {
                        Request($0)
                            .path(appending: "Test.json")
                            .publish(with: session)
                            .assertBackgroundThread()
                    }
                    .map(\.data)
                    .wrap()
                    .compactMap { $0["string"].string() }
                    .assertBackgroundThread()
            }
            .receive(on: RunLoop.main.cx)
            .assertMainThread()
        }
        .unlock(with: url)
        .session(.shared)
        .sink(
            receiveCompletion: {
                if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
                expectations.last?.fulfill()
            },
            receiveValue: {
                XCTAssert($0 == "A random string.")
                expectations.first?.fulfill()
            }
        )
        .store(in: &bin)
        wait(for: expectations, timeout: 30)
    }
    
    /// Test remote promises.
    func testRemoteFuture() {
        let expectations = ["output", "completion"].map(XCTestExpectation.init)
        Just(url)
            .assertMainThread()
            .receive(on: RunLoop.main.cx)
            .assertMainThread()
            .flatMap {
                Request($0)
                    .publish(session: .shared)
                    .assertBackgroundThread()
                    .map(\.data)
                    .wrap()
                    .compactMap { $0["string"].string() }
            }
            .subscribe(on: RunLoop.main.cx)
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
                    expectations.last?.fulfill()
                },
                receiveValue: {
                    XCTAssert($0 == "A random string.")
                    expectations.first?.fulfill()
                }
            )
            .store(in: &bin)
        wait(for: expectations, timeout: 30)
    }
    
    // MARK: Pagination
    
    /// Test a paginated fetch request.
    func testPagination() {
        let languages = ["en", "it", "de", "fr"]
        let expectations = languages.map(XCTestExpectation.init)+[XCTestExpectation(description: "completion")]
        let offset = Reference(0)
        // Prepare the provider.
        PagerProvider { pages in
            // Actually paginate futures.
            Pager(pages) { offset in
                LockProvider {  // Additional test.
                    Just($0).map { _ in offset }
                }
                .unlock(with: languages[offset])
                .iterateFirst(stoppingAt: offset) { $0+1 }
            }
        }
        .pages(languages.count, offset: 0)
        .receive(on: RunLoop.main.cx)
        .assertMainThread()
        .sink(
            receiveCompletion: {
                if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
                expectations.last?.fulfill()
            },
            receiveValue: {
                XCTAssert(offset.value == $0)
                offset.value = $0+1
                expectations[$0].fulfill()
            }
        )
        .store(in: &bin)
        wait(for: expectations, timeout: 30)
    }
    
    /// Test a remote paginated fetch request.
    func testRemotePagination() {
        let languages = ["en", "it", "de", "fr"]
        let expectations = languages.map(XCTestExpectation.init)+[XCTestExpectation(description: "completion")]
        let offset = Reference(0)
        // Prepare the provider.
        LockSessionPagerProvider { url, session, pages in    // Additional tests.
            // Actually paginate futures.
            Pager(pages) { offset in
                Request(url)
                    .query(appending: languages[offset], forKey: "l")
                    .publish(with: session)
                    .map { _ in offset }
                    .iterateLast { ($0 ?? -1)+1 }
            }
        }
        .unlock(with: url)
        .session(.shared)
        .pages(languages.count, offset: 0)
        .sink(
            receiveCompletion: {
                if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
                expectations.last?.fulfill()
            },
            receiveValue: {
                XCTAssert(offset.value == $0)
                offset.value = $0+1
                expectations[$0].fulfill()
            }
        )
        .store(in: &bin)
        wait(for: expectations, timeout: 30*TimeInterval(languages.count))
    }
    
    // MARK: Cancellation
    
    /// Test cancellation.
    func testCancellation() {
        let expectations = ["completion"].map(XCTestExpectation.init)
        Request(url)
            .publish(session: .shared)
            .map(\.response)
            .receive(on: RunLoop.main.cx)
            .sink(
                receiveCompletion: { _ in XCTFail("This should not complete") },
                receiveValue: { _ in XCTFail("This should not output") }
            )
            .store(in: &bin)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.bin.removeAll()
            expectations.first?.fulfill()
        }
        wait(for: expectations, timeout: 5)
    }
    
    /// Test cancellation recover.
    func testCancellationRecovery() {
        let expectations = ["completion"].map(XCTestExpectation.init)
        Request(url)
            .publish(session: .shared)
            .assertMainThread()
            .compactMap(\.response.url?.absoluteString)
            .catch { _ in Just("test") }
            .receive(on: RunLoop.main.cx)
            .sink(
                receiveCompletion: { _ in XCTFail("This should not complete") },
                receiveValue: { _ in XCTFail("This should not output") }
            )
            .store(in: &bin)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.bin.removeAll()
            expectations.first?.fulfill()
        }
        wait(for: expectations, timeout: 5)
    }
    
    /// Test paginated cancellation.
    func testPaginatedCancellation() {
        let expectations = ["output", "completion"].map(XCTestExpectation.init)
        expectations[0].assertForOverFulfill = true
        expectations[0].expectedFulfillmentCount = 1
        Pager(3) {
            Request(url)
                .publish(session: .shared)
                .map(\.response)
        }
        .sink(
            receiveCompletion: { _ in
                XCTFail("This should not complete")
            },
            receiveValue: { _ in
                expectations.first?.fulfill()
                self.bin.removeAll()
            }
        )
        .store(in: &bin)
        DispatchQueue.main.asyncAfter(deadline: .now()+25) { expectations.last?.fulfill() }
        wait(for: expectations, timeout: 30)
    }
}
