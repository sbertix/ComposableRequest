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
}
