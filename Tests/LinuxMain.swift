import XCTest

import ComposableRequestTests

var tests = [XCTestCaseEntry]()
tests += CombineTests.allTests()
tests += ComposableTests.allTests()
tests += ExtensionsTests.allTests()
tests += RequestTests.allTests()
XCTMain(tests)
