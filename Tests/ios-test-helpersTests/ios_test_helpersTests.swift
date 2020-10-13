import XCTest
@testable import ios_test_helpers

final class ios_test_helpersTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ios_test_helpers().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
