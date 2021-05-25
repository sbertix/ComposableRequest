//
//  DeprecationsTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 25/05/21.
//

import Combine
import XCTest

@testable import ComposableRequest

/// A `class` defining a series of tests on deprecated definitions.
internal final class DeprecationsTests: XCTestCase {
    // MARK: Removing starting with `6.0.0`

    // swiftlint:disable line_length
    /// Test concat providers.
    func testConcatProviders() {
        typealias Lock = ConcatProvider<LockProvider<Int, LockProvider<Int, Int>>,
                                        LockProvider<Int, Int>>
        XCTAssertEqual(Lock { $0+$1 }.unlock(with: 1).unlock(with: 2), 3)

        typealias Lock3 = ConcatProvider3<LockProvider<Int, LockProvider<Int, LockProvider<Int, Int>>>,
                                          LockProvider<Int, LockProvider<Int, Int>>,
                                          LockProvider<Int, Int>>
        XCTAssertEqual(Lock3 { $0+$1+$2 }.unlock(with: 1).unlock(with: 2).unlock(with: 3), 6)

        typealias Lock4 = ConcatProvider4 <LockProvider<Int, LockProvider<Int, LockProvider<Int, LockProvider<Int, Int>>>>,
                                           LockProvider<Int, LockProvider<Int, LockProvider<Int, Int>>>,
                                           LockProvider<Int, LockProvider<Int, Int>>,
                                           LockProvider<Int, Int>>
        XCTAssertEqual(Lock4 { $0+$1+$2+$3 }.unlock(with: 1).unlock(with: 2).unlock(with: 3).unlock(with: 4), 10)

        typealias Lock5 = ConcatProvider5 <LockProvider<Int, LockProvider<Int, LockProvider<Int, LockProvider<Int, LockProvider<Int, Int>>>>>,
                                           LockProvider<Int, LockProvider<Int, LockProvider<Int, LockProvider<Int, Int>>>>,
                                           LockProvider<Int, LockProvider<Int, LockProvider<Int, Int>>>,
                                           LockProvider<Int, LockProvider<Int, Int>>,
                                           LockProvider<Int, Int>>
        XCTAssertEqual(Lock5 { $0+$1+$2+$3+$4 }.unlock(with: 1).unlock(with: 2).unlock(with: 3).unlock(with: 4).unlock(with: 5), 15)

        XCTAssertEqual(
            Lock5 { one in
                Lock4 { two in
                    Lock3 { three in
                        Lock { four in
                            .init { five in
                                one + two + three + four + five
                            }
                        }
                    }
                }
            }
            .unlock(with: 1)
            .unlock(with: 2)
            .unlock(with: 3)
            .unlock(with: 4)
            .unlock(with: 5),
            15
        )
    }
    // swiftlint:enable line_length
}
