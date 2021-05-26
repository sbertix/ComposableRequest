//
//  ObservableTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import Combine
import XCTest

@testable import ComposableRequest

// swiftlint:disable force_unwrapping
/// A url to a json resource.
private let url = URL(string: ["https://gist.githubusercontent.com/sbertix/",
                               "8959f2534f815ee3f6018965c6c5f9e2/raw/",
                               "c38d855d9aac95fb095b6c5fc75f9a0219183648/Test.json"].joined())!
// swiftlint:enable force_unwrapping

/// A `class` defining a series of tests on `Observable`s.
internal final class ObservableTests: XCTestCase {
    /// The dispose bag.
    private var bin: Set<AnyCancellable> = []

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
                    .map(Optional.some) // Additional tests.
                    .wrap()
                    .compactMap { $0["string"].string() }
                    .assertBackgroundThread()
            }
            .receive(on: RunLoop.main)
            .assertMainThread()
        }
        .unlock(with: url)
        .session(.shared, logging: .init(level: .all) { _ in })
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
            .setFailureType(to: Error.self)
            .assertMainThread()
            .receive(on: RunLoop.main)
            .assertMainThread()
            .flatMap {
                Request($0)
                    .publish(session: .shared)
                    .assertBackgroundThread()
                    .map(\.data)
                    .wrap()
                    .compactMap { $0["string"].string() }
            }
            .subscribe(on: RunLoop.main)
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
        // swiftlint:disable line_length
        typealias Lock = LockProvider<Int, LockProvider<Void, LockProvider<Void, LockProvider<Void, LockProvider<Void, Just<Int>>>>>>
        // swiftlint:enable line_length

        let date = Date()
        let expectations = ((0...4).map(String.init) + ["completion"]).map(XCTestExpectation.init)
        PagerProvider {
            Pager($0) { offset in
                Lock { value, _, _, _, _ in
                    Just(value)
                }
                .unlock(with: offset)
                .unlock()
                .unlock()
                .unlock()
                .unlock()
                .iterateFirst { .load($0 + 1) }
            }
        }
        .pages(5, offset: 0, delay: .seconds(1))
        .sink {
            if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
            expectations.last?.fulfill()
        } receiveValue: {
            expectations[$0].fulfill()
        }
        .store(in: &bin)

        wait(for: expectations, timeout: 10)
        XCTAssertLessThan(date.timeIntervalSinceNow, -4)
    }

    /// Test a pagination request using a ranked offset.
    func testRankedOffsetPagination() {
        let values = Array(0...3)
        let expectations = ["0", "1", "2", "3", "completion"].map(XCTestExpectation.init)
        let offset = Atomic(0)
        // Prepare the provider.
        PagerProvider { (pages: PagerProviderInput<RankedOffset<Int, [Int]>>) in
            Pager(pages) { Just(pages.rank[$0]).iterateFirst { .load($0 + 1) } }
        }
        .pages(values.count, offset: 0, rank: values)
        .sink {
            if case .failure(let error) = $0 { XCTFail(error.localizedDescription) }
            expectations.last?.fulfill()
        }
        receiveValue: { value in
            offset.sync {
                XCTAssert(value == $0)
                expectations[value].fulfill()
                $0 = value + 1
            }
        }
        .store(in: &bin)
        wait(for: expectations, timeout: 30)
    }

    // MARK: Cancellation

    /// Test cancellation.
    func testCancellation() {
        let expectations = ["completion"].map(XCTestExpectation.init)
        Request(url)
            .publish(session: .shared)
            .map(\.response)
            .receive(on: RunLoop.main)
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
}
