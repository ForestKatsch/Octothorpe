
import OctoIRC
import XCTest

final class IRCClientTests: XCTestCase {
    func testClientCreation() async throws {
        let transport = TestTransport()
        let options = IRCClient.Options(.init(nickname: .init("DeltaOne"), realName: "Jason Bourne")!)
        let client = IRCClient(transport, options: options)

        try await client.connect()

        XCTAssertEqual(transport.sent.count, 4)
    }
}
