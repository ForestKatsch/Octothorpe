
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

    var sent: [OctoIRC.Message] = []

    func send(_ message: OctoIRC.Message) async throws {
        sent.append(message)
    }
}
