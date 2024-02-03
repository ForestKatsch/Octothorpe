
import OctoIRC
import XCTest

final class NicknameTests: XCTestCase {
    func testEmptyFails() throws {
        XCTAssertNil(Nickname(string: ""))
    }

    func testFirstLetterFails() throws {
        XCTAssertNil(Nickname(string: "$"))
        XCTAssertNil(Nickname(string: ":"))
        XCTAssertNil(Nickname(string: "#"))
        XCTAssertNil(Nickname(string: "&"))
        XCTAssertNil(Nickname(string: "~"))
        XCTAssertNil(Nickname(string: "@"))
        XCTAssertNil(Nickname(string: "%"))
        XCTAssertNil(Nickname(string: "+"))
    }

    func testInvalidNicknames() throws {
        XCTAssertNil(Nickname(string: " "))
        XCTAssertNil(Nickname(string: ","))
        XCTAssertNil(Nickname(string: "*"))
        XCTAssertNil(Nickname(string: "?"))
        XCTAssertNil(Nickname(string: "!"))
        XCTAssertNil(Nickname(string: "@"))
    }

    func testValidNicknames() throws {
        XCTAssertNotNil(Nickname(string: "zlsa"))
        XCTAssertNotNil(Nickname(string: "wombo_combo"))
        XCTAssertNotNil(Nickname(string: "f"))
        XCTAssertNotNil(Nickname(string: "X"))
        XCTAssertNotNil(Nickname(string: "Hello-World+"))
    }
}
