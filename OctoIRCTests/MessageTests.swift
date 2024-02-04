
import OctoIRC
import XCTest

final class MessageTests: XCTestCase {
    func testMessageCreation() throws {
        XCTAssertEqual(RawMessage(.CAP).message, "CAP")
        XCTAssertEqual(RawMessage(.CAP, ["*"]).message, "CAP *")
    }

    func testFinalParameter() throws {
        XCTAssertEqual(RawMessage(.CAP, [""]).message, "CAP :")
        XCTAssertEqual(RawMessage(.CAP, [":"]).message, "CAP ::")
        XCTAssertEqual(RawMessage(.CAP, ["hello world"]).message, "CAP :hello world")
        XCTAssertEqual(RawMessage(.CAP, ["hello"]).message, "CAP hello")
    }

    func testSpecificMessages() throws {
        let commands = [
            RawMessage(.CAP),
            RawMessage(.CAP, [""]),
            RawMessage(.CAP, [" "]),
            RawMessage(.CAP, [":"]),
            RawMessage(.CAP, ["Hello, world"]),
            RawMessage(.CAP, ["Hi", "Hello, world"]),
            RawMessage(.CAP, ["Hi:", "Hello, world"]),
            RawMessage(.CAP, ["Hi#?", "Hello, world"]),
            RawMessage(.CAP, ["Hi#?", "  Hello, world     "]),
            RawMessage(source: .serverName("irc.net"), .CAP),
            RawMessage(source: .serverName("irc"), .CAP),
            RawMessage(source: .user(.init(nickname: .init(string: "DeltaOne"))), .CAP),
            RawMessage(source: .user(.init(nickname: .init(string: "DeltaOne"), host: "127.0.0.1")), .CAP),
            RawMessage(source: .user(.init(nickname: .init(string: "DeltaOne"), user: "DeltaOne__", host: "127.0.0.1")), .CAP),
            RawMessage(source: .user(.init(nickname: .init(string: "DeltaOne"), user: "DeltaOne__")), .CAP),
        ]
        commands.forEach {
            XCTAssertEqual(RawMessage(string: $0.message)?.message ?? "", $0.message)
        }
    }

    func testMalformedParsing() throws {
        // Malformed but not invalid.
        let valid = [
            "CAP   :hey",
            " CAP   hey",
        ]

        valid.forEach {
            XCTAssertNotNil(RawMessage(string: $0))
        }
    }

    func testInvalidParsing() throws {
        let invalid = [
            "CAP:",
            "",
        ]

        invalid.forEach {
            XCTAssertNil(RawMessage(string: $0))
        }
    }
}
