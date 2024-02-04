
import OctoIRC
import XCTest

final class MessageTests: XCTestCase {
    func testMessageCreation() throws {
        XCTAssertEqual(Message(.CAP).message, "CAP")
        XCTAssertEqual(Message(.CAP, ["*"]).message, "CAP *")
    }

    func testFinalParameter() throws {
        XCTAssertEqual(Message(.CAP, [""]).message, "CAP :")
        XCTAssertEqual(Message(.CAP, [":"]).message, "CAP ::")
        XCTAssertEqual(Message(.CAP, ["hello world"]).message, "CAP :hello world")
        XCTAssertEqual(Message(.CAP, ["hello"]).message, "CAP hello")
    }

    func testSpecificMessages() throws {
        let commands = [
            Message(.CAP),
            Message(.CAP, [""]),
            Message(.CAP, [" "]),
            Message(.CAP, [":"]),
            Message(.CAP, ["Hello, world"]),
            Message(.CAP, ["Hi", "Hello, world"]),
            Message(.CAP, ["Hi:", "Hello, world"]),
            Message(.CAP, ["Hi#?", "Hello, world"]),
            Message(.CAP, ["Hi#?", "  Hello, world     "]),
            Message(source: .serverName("irc.net"), .CAP),
            Message(source: .serverName("irc"), .CAP),
            Message(source: .user(.init(nickname: .init(string: "DeltaOne"))), .CAP),
            Message(source: .user(.init(nickname: .init(string: "DeltaOne"), host: "127.0.0.1")), .CAP),
            Message(source: .user(.init(nickname: .init(string: "DeltaOne"), user: "DeltaOne__", host: "127.0.0.1")), .CAP),
            Message(source: .user(.init(nickname: .init(string: "DeltaOne"), user: "DeltaOne__")), .CAP),
        ]
        commands.forEach {
            XCTAssertEqual(Message(string: $0.message)?.message ?? "", $0.message)
        }
    }

    func testMalformedParsing() throws {
        // Malformed but not invalid.
        let valid = [
            "CAP   :hey",
            " CAP   hey",
        ]

        valid.forEach {
            XCTAssertNotNil(Message(string: $0))
        }
    }

    func testInvalidParsing() throws {
        let invalid = [
            "CAP:",
            "",
        ]

        invalid.forEach {
            XCTAssertNil(Message(string: $0))
        }
    }
}
