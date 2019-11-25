import XCTest
@testable import BWKit

final class BWKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BWKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
