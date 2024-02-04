
import Foundation
import OctoIRC

class TestTransport: IRCTransport {
    static func == (_: TestTransport, _: TestTransport) -> Bool {
        true
    }

    func hash(into _: inout Hasher) {}

    var name: String = "test"

    var received: ((String) async -> Void)?

    func connect() async throws {
        // Do nothing
    }

    var sent: [OctoIRC.RawMessage] = []

    func send(_ message: OctoIRC.RawMessage) async throws {
        sent.append(message)
    }
}
