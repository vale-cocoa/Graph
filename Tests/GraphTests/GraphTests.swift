import XCTest
@testable import Graph

final class GraphTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Graph().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
