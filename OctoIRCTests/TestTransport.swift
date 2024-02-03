
import Foundation
import OctoIRC

class TestTransport: IRCTransport {
    var received: ((String) -> Void)?

    func connect() async throws {
        // Do nothing
    }

    var sent: [OctoIRC.Message] = []

    func send(_ message: OctoIRC.Message) async throws {
        sent.append(message)
    }
}
