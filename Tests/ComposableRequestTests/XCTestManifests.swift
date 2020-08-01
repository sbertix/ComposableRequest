//
//  ComposableTests.swift
//  ComposableRequestTests
//
//  Created by Stefano Bertagno on 06/05/2020.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CombineTests.allTests),
        testCase(ComposableTests.allTests),
        testCase(ExtensionsTests.allTests),
        testCase(RequestTests.allTests),
        testCase(ResponseTests.allTests),
        testCase(StorageTests.allTests)
    ]
}
#endif
