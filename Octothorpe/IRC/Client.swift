
import Foundation
import OctoIRC
import SwiftUI

@Observable
class Client: IRCClient {
    static let shared: Client = {
        var options = IRCClient.Options(.init(nickname: Nickname(string: "ROBOT")!, username: "robot_username", realName: "Roland Bottas"))
        // options.serverPassword = "alleightofus"

        return Client(options)
    }()

    init(_ options: IRCClient.Options) {
        super.init(NetworkTransport("ceres", port: 6667)!, options: options)
        // super.init(NetworkTransport("zlsadesign.com", port: 6667)!, options: options)
    }

    /*
     // try await onReceive(.USER())
     try await join(channel: "#octothorpe")

     try await send(.PRIVMSG("#octothorpe", message: "Hello fuckers"))

     */
}
