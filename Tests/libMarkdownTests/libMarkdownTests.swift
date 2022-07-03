import XCTest
@testable import libMarkdown

final class libMarkdownTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(libMarkdown().text, "Hello, World!")
    }
}
