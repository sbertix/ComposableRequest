//
//  PagerTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 25/05/21.
//

import Foundation
import XCTest

@testable import ComposableRequest

/// A `class` defining `Pager`-specific tests.
internal class PagerTests: XCTestCase {
    /// Test pager provders.
    func testPagerProvider() {
        let provider = PagerProvider<RankedOffset<Int, Int>, Int> {
            $0.count+$0.offset.offset+$0.rank + Int($0.delay($0.offset).magnitude)
        }
        XCTAssertEqual(PagerProviderInput(count: 0, offset: 1, delay: 2).delay(0),
                       PagerProviderInput(count: 0, offset: 1) { $0 }.delay(2))
        XCTAssertEqual(RankedOffset(offset: 1, rank: 2), RankedOffset(offset: 1, rank: 3))

        XCTAssertEqual(provider.pages(1, offset: .init(offset: 2, rank: 3)) { _ in .seconds(4) }, 10)
        XCTAssertEqual(provider.pages(1, offset: .init(offset: 2, rank: 3)), 6)

        let closedRange = provider.pages(1, offset: .init(offset: 2, rank: 3), delay: 4..<5)
        XCTAssertGreaterThanOrEqual(closedRange, 10)
        XCTAssertLessThan(closedRange, 11)

        let openRange = provider.pages(1, offset: .init(offset: 2, rank: 3), delay: 4...5)
        XCTAssertGreaterThanOrEqual(openRange, 10)
        XCTAssertLessThanOrEqual(openRange, 11)

        XCTAssertEqual(provider.pages(1, offset: .init(offset: 2, rank: 3), delay: 4), 10)
    }

    /// Test `Void`-input pager providers.
    func testVoidInputPagerProvider() {
        let provider = PagerProvider<Void, Int> { $0.count + Int($0.delay($0.offset).magnitude) }
        XCTAssertEqual(provider.pages(1, delay: .seconds(2)), 3)
    }

    /// Test `ComposableOptionalType`-input pager providers.
    func testComposableOptionalTypePagerProvider() {
        let provider = PagerProvider<Int?, Int> { $0.count + Int($0.delay($0.offset).magnitude) + ($0.offset ?? 0) }
        XCTAssertEqual(provider.pages(1, delay: .seconds(2)), 3)
    }

    /// Test `Ranked`-input pager providers.
    func testRankedPagerProvider() {
        let provider = PagerProvider<RankedOffset<Int, Int>, Int> {
            $0.count+$0.offset.offset+$0.rank + Int($0.delay($0.offset).magnitude)
        }
        XCTAssertEqual(provider.pages(1, offset: 2, rank: 3, delay: .seconds(4)), 10)
    }

    /// Test optional-`Rank` `Ranked`-input pager providers.
    func testRankedOptionalPagerProvider() {
        let offset = PagerProvider<RankedOffset<Int?, Int>, Int> {
            $0.count + ($0.offset.offset ?? 0)+$0.rank + Int($0.delay($0.offset).magnitude)
        }
        XCTAssertEqual(offset.pages(1, rank: 2, delay: .seconds(3)), 6)

        let rank = PagerProvider<RankedOffset<Int, Int?>, Int> {
            $0.count+$0.offset.offset + ($0.rank ?? 0) + Int($0.delay($0.offset).magnitude)
        }
        XCTAssertEqual(rank.pages(1, offset: 2, delay: .seconds(3)), 6)
    }

    /// Test optional `Ranked`-input pager providers.
    func testOptionalRankedPagerProvider() {
        let provider = PagerProvider<RankedOffset<Int?, Int?>, Int> {
            $0.count + ($0.offset.offset ?? 0) + ($0.rank ?? 0) + Int($0.delay($0.offset).magnitude)
        }
        XCTAssertEqual(provider.pages(1, delay: .seconds(2)), 3)
    }

    /// Test iterations.
    func testIterations() {
        /// Compare equality.
        ///
        /// - parameters:
        ///     - instruction: A valid `Instruction`.
        ///     - value: Some value.
        func compare<T: Equatable>(_ instruction: Instruction<T>, _ value: T) {
            switch instruction {
            case .stop:
                XCTFail("Iteration stopped.")
            case .load(let next):
                XCTAssertEqual(next, value)
            }
        }

        /// Compare to stop.
        ///
        /// - parameter instruction: A valid `Instruction`.
        func compare<T>(stop instruction: Instruction<T>) {
            switch instruction {
            case .stop:
                break
            case .load:
                XCTFail("Iteration should stop.")
            }
        }

        compare(Just(1).iterate { .load($0.reduce(into: 0) { $0 += $1 }+1) }.offset([0]), 1)
        compare(stop: Just(1).iterate { $0 == 1 } with: { .load(($0.first ?? -1) + 1) }.offset([0]))
        compare(stop: Just(1).iterate(stoppingAt: 1) { .load(($0.first ?? -1) + 1) }.offset([0]))
        compare(Just(1).iterateFirst { .load(($0 ?? -1) + 1) }.offset([0]), 1)
        compare(stop: Just(1).iterateFirst { $0 == 1 } with: { .load(($0 ?? -1) + 1) }.offset([0]))
        compare(stop: Just(1).iterateFirst(stoppingAt: 1) { .load(($0 ?? -1) + 1) }.offset([0]))
        compare(Just(1).iterateLast { .load(($0 ?? -1) + 1) }.offset([0]), 1)
        compare(stop: Just(1).iterateLast { $0 == 1 } with: { .load(($0 ?? -1) + 1) }.offset([0]))
        compare(stop: Just(1).iterateLast(stoppingAt: 1) { .load(($0 ?? -1) + 1) }.offset([0]))
        compare(stop: Just(()).iterate { _ in false }.offset([()]))

        compare(Just(1).iterateFirst { .load($0 + 1) }.offset([0]), 1)
        compare(stop: Just(1).iterateFirst { $0 == 1 } with: { .load($0 + 1) }.offset([0]))
        compare(stop: Just(1).iterateFirst(stoppingAt: 1) { .load($0 + 1) }.offset([0]))
        compare(Just(1).iterateLast { .load($0 + 1) }.offset([0]), 1)
        compare(stop: Just(1).iterateLast { $0 == 1 } with: { .load($0 + 1) }.offset([0]))
        compare(stop: Just(1).iterateLast(stoppingAt: 1) { .load($0 + 1) }.offset([0]))

        compare(Just(Page(offset: 1)).iterateFirst().offset([Page(offset: 0)]), 0)
        compare(stop: Just(Page(offset: 1)).iterateFirst { $0 == 0 }.offset([Page(offset: 0)]))
        compare(Just(Page(offset: 1)).iterateLast().offset([Page(offset: 0)]), 0)
        compare(stop: Just(Page(offset: 1)).iterateFirst { $0 == 0 }.offset([Page(offset: 0)]))

        compare(stop: Just(Page(offset: 1)).iterateFirst(stoppingAt: 0).offset([Page(offset: 0)]))
        compare(stop: Just(Page(offset: 1)).iterateLast(stoppingAt: 0).offset([Page(offset: 0)]))
    }
}

fileprivate extension PagerTests {
    /// A `struct` defining a custom `Paginatable`.
    struct Page: Paginatable {
        let offset: Offset
    }
}

fileprivate extension PagerTests.Page {
    typealias Offset = Int?
}
