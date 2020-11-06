import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(ios_test_helpersTests.allTests)
    ]
}
#endif
