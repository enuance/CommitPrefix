import XCTest

import commitPrefixTests

var tests = [XCTestCaseEntry]()
tests += commitPrefixTests.allTests()
XCTMain(tests)
